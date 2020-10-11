import os
import boto3
import re
import requests
from requests_aws4auth import AWS4Auth
import json
from urllib.parse import unquote_plus
import googlemaps 

region = 'ap-northeast-1' # e.g. us-west-1
service = 'es'
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

host = os.environ['ES_DOMAIN'] # the Amazon ES domain, including https://
index = os.environ['ES_INDEX']
type = os.environ['ES_TYPE']
url = host + '/' + index + '/' + '_doc'#type

headers = { "Content-Type": "application/json" }

s3 = boto3.client('s3')

# google map api
gmap = googlemaps.Client(key=os.environ['GOOGLE_MAP_API_KEY'])

# Lambda execution starts here
def handler(event, context):
    for record in event['Records']:

        # Get the bucket name and key for the new file
        bucket = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])
        print({'bucket': bucket, 'key': key})

        # Get, read, and split the file into lines
        obj = s3.get_object(Bucket=bucket, Key=key)
        body = obj['Body'].read()
        document  = json.loads(body)
        geocode = gmap.geocode(document['address'])
        lat = geocode[0]["geometry"]["location"]["lat"]
        lon = geocode[0]["geometry"]["location"]["lng"]
        document['geo'] = {'lat': lat, 'lon': lon}
        print(document)
        r = requests.post(url, auth=awsauth, json=document, headers=headers)
        print(r.text)
