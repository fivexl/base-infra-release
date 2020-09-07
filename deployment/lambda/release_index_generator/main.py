from botocore.exceptions import ClientError
from boto3 import client
from os import path
from jinja2 import Environment, FileSystemLoader
from urllib.parse import unquote_plus

s3_client = client('s3')
env = Environment(loader=FileSystemLoader(path.join(path.dirname(__file__), 'templates'), encoding='utf8'))
template = env.get_template('index.html')


def generate_elements(bucket, folder_key):
    print(folder_key)
    response = s3_client.list_objects_v2(
        Bucket=bucket,
        Prefix=folder_key
    )


def resize_image(key, bucket):
    tmpkey = key.replace('/', '')
    download_path = '/tmp/{}{}'
    upload_path = '/tmp/resized-{}'.format(tmpkey)
    s3_client.download_file(bucket, key, download_path)
    resize_image(download_path, upload_path)
    s3_client.upload_file(upload_path, '{}-resized'.format(bucket), key)


def lambda_handler(event, context):
    print(event)
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        print(bucket)
        print(record['s3']['object']['key'])
        key = unquote_plus(record['s3']['object']['key'])
        print(key)
        generate_elements(bucket, key)
