from botocore.exceptions import ClientError
from os import path, environ, makedirs
from jinja2 import Environment, FileSystemLoader
import boto3
import time
import tempfile
import json

env = Environment(loader=FileSystemLoader(path.join(path.dirname(__file__), 'templates'), encoding='utf8'))
template = env.get_template('index.html')

# For local testing
WRITE_TO_S3 = True
DESTINATION = ''

def create_index_for_app(bucket_name, app):
    links = dict()
    objects_to_invalidate = list()

    versions = get_prefixes(bucket_name, f'{app}/')
    print(f'{app} versions: {versions}')
    for version in versions:
        links[f'{app}_{version}'] = f'/{app}/{version}/index.html'

    print(f'{app} links: {links}')
    objects_to_invalidate += links.values()

    object_content = template.render(links=links, ref_back='/index.html')
    write_object(bucket_name, app, object_content)

    for version in versions:
        file_links = dict()
        files = get_all_objects(bucket_name, f'{app}/{version}/')
        for file in files:
            if file.endswith('index.html'):
                continue
            file_links[f'{file}'] = f'/{app}/{version}/{file}'
        print(f'{app}/{version} links: {file_links}')
        object_content = template.render(links=file_links, ref_back=f'/{app}/index.html')
        write_object(bucket_name, f'{app}/{version}', object_content)

    return objects_to_invalidate


def update_main_index(bucket_name, apps):
    links = dict()
    objects_to_invalidate = []
    for app in apps:
        links[app] = f'/{app}/index.html'

    print(f'top level links: {links}')
    objects_to_invalidate += links.values()

    object_content = template.render(links=links, ref_back='')
    write_object(bucket_name, '', object_content)

    return objects_to_invalidate


def write_object(bucket_name, prefix, object_content):
    object_path = f'{prefix}/index.html' if prefix else 'index.html'
    if WRITE_TO_S3:
        print(f'Writing {bucket_name}/{object_path}')
        client = boto3.client('s3')
        client.put_object(
            Body=object_content,
            Bucket=bucket_name,
            Key=object_path,
            ContentType='text/html')
    else:
        if not path.isdir(path.join(DESTINATION, prefix)):
            makedirs(path.join(DESTINATION, prefix))
        with open(path.join(DESTINATION, object_path), 'a') as out:
            print(f'Writing {out.name}')
            out.write(object_content)


def get_prefixes(bucket, prefix=''):
    client = boto3.client('s3')
    paginator = client.get_paginator('list_objects')
    result = paginator.paginate(Bucket=bucket, Delimiter='/', Prefix=prefix)
    prefixes = list()
    for common_prefix in result.search('CommonPrefixes'):
        result = common_prefix.get('Prefix').rstrip('/')
        if prefix:
            result = result.split('/')[-1]
        prefixes.append(result)
    return prefixes


def get_all_objects(bucket_name, prefix=''):
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucket_name)
    objects = list()
    for object_summary in bucket.objects.filter(Prefix=prefix):
        objects.append(object_summary.key.split('/')[-1])
    return objects


def lambda_handler(event, context):
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    distribution_id = environ.get('DISTRIBUTION_ID', '')

    print(f'Triggered for {bucket_name}/{key}')

    # Do nothting if we get triggered on index.html since we generate them
    if key.endswith('index.html'):
        print('Do nothing for index.html')
        return {'statusCode': 200}

    objects_to_invalidate = ['/index.html']

    apps = get_prefixes(bucket_name)
    objects_to_invalidate += update_main_index(bucket_name, apps)

    for app in apps:
        objects_to_invalidate += create_index_for_app(bucket_name, app)

    if distribution_id:
        print(f'going to invalidate: {objects_to_invalidate}')

        cloudfront = boto3.client('cloudfront')
        invalidation = cloudfront.create_invalidation(
            DistributionId=distribution_id,
            InvalidationBatch={
                'Paths': {
                    'Quantity': len(objects_to_invalidate),
                    'Items': objects_to_invalidate
                },
            'CallerReference': str(time.time()).replace(".", "")
        }
        )
        print(f'Created invalidation_id = {invalidation["Invalidation"]["Id"]}')

    return {
        'statusCode': 200
    }


# For local testing
if __name__ == '__main__':
    DESTINATION = tempfile.mkdtemp()
    WRITE_TO_S3 = False
    print(f'DESTINATION = {DESTINATION}')
    print(f'WRITE_TO_S3 = {WRITE_TO_S3}')
    event = '''
{
  "Records": [
    {
      "s3": {
        "bucket": {
          "name": "release-013803cc9fe0903d4c12dd9f8cb67f668d589098"
        },
        "object": {
          "key": "test%2Fkey"
        }
      }
    }
  ]
}
'''
    lambda_handler(json.loads(event), None)