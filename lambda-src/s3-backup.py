import boto3
import os
from botocore.exceptions import ClientError

def init_conf():
    global arn
    global region
    arn = os.environ.get('ROLEARN')
    arn = 'arn:aws:iam::' + arn + ':role/OrganizationAccountAccessRole' 
    region = os.environ.get('REGION')

def lambda_handler(event, context):
    init_conf()