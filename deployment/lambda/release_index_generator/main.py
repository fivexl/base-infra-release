from botocore.exceptions import ClientError
from boto3 import client, resource
from os import path
from jinja2 import Environment, FileSystemLoader

s3_client = client('s3')
s3_resource = resource('s3')
env = Environment(loader=FileSystemLoader(path.join(path.dirname(__file__), 'templates'), encoding='utf8'))
template = env.get_template('index.html')


def format_files(files):
    my_list = files
    apps = dict()
    for item in my_list:
        if "/" not in item:
            my_list.remove(item)
    for item in my_list:
        split = item.split("/")
        apps.setdefault(split[0], set()).add(split[1])
    for item in my_list:
        split = item.split("/")
        if len(split) <= 2:
            my_list.remove(item)
    return {"applications": apps, "files": my_list}


def create_index_for_app(bucket_name, info):
    for app, versions in info['applications'].items():
        element_app_li = "<li>\n  <a href=\"/" + "\"> ... </a>\n</li>"
        for ver in versions:
            element_ver_li = "<li>\n  <a href=\"/" + app + "/" + "\"> ... </a>\n</li>"
            for file in info['files']:
                if (file.find(app) >= 0) and (file.find(ver) >= 0):
                    element_ver_li = element_ver_li + "\n<li>\n  <a href=\"/" + file + "\">" + file.rsplit("/", 1)[1] + "</a>\n</li>"
            index_html_s3 = s3_resource.Object(bucket_name, app + "/" + ver + "/" + "index.html")
            index_html_s3.put(
                ACL='public-read',
                Body=template.render(elements=element_ver_li),
                ContentType='text/html'
            )
            element_app_li = element_app_li + "\n<li>\n  <a href=\"/" + app + "/" + ver + "\">" + app + "_" + ver + "</a>\n</li>"
        index_html_s3 = s3_resource.Object(bucket_name, app + "/index.html")
        index_html_s3.put(
            ACL='public-read',
            Body=template.render(elements=element_app_li),
            ContentType='text/html'
        )
    return "OK"


def update_main_index(bucket_name):
    element_main_li = ""
    all_apps = set()
    for file in s3_resource.Bucket(bucket_name).objects.all():
        if not file.key.endswith("index.html"):
            all_apps.add(file.key.split("/")[0])
    for all_app in all_apps:
        element_main_li = element_main_li + "\n<li>\n  <a href=\"/" + all_app + "/" + "\">" + all_app + "</a>\n</li>"
    index_html_s3 = s3_resource.Object(bucket_name, "index.html")
    index_html_s3.put(
        ACL='public-read',
        Body=template.render(elements=element_main_li),
        ContentType='text/html'
    )
    return "OK"


def lambda_handler(event, context):
    files = []
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    app = key.split("/")[0]
    app_objs = s3_client.list_objects_v2(
        Bucket=bucket,
        Prefix=app
    )
    print("S3 objects:", app_objs)
    if app_objs['KeyCount'] > 1:
        for obj in app_objs['Contents']:
            key = obj['Key']
            if not key.endswith("index.html"):
                if key.endswith("/"):
                    files.append(key[:-1])
                else:
                    files.append(key)
    formatted_files = format_files(sorted(files))
    status_index_for_app = create_index_for_app(bucket, formatted_files)
    status_index_main  = update_main_index(bucket)
    return {
        'statusCode': 200,
        'body': {'status_index_for_app': status_index_for_app, 'status_index_main': status_index_main}
    }
