import boto3
import os
from botocore.exceptions import ClientError

BackupString = str("'Key': 'BackupEnabled', 'Value': 'True'")
NoBackupString = str("'Key': 'BackupEnabled', 'Value': 'False'")

def init_conf():
    global arn
    global region
    arn = os.environ.get('ROLEARN')
    arn = 'arn:aws:iam::' + arn + ':role/OrganizationAccountAccessRole' 
    region = os.environ.get('REGION')

def assumeCredentials(service_id, role_arn):
    sts = boto3.client('sts')
    session_name = 'Session-' + service_id + '-Lambda'
    assumed_role_object = sts.assume_role ( RoleArn=role_arn, RoleSessionName=session_name)
    credentials=assumed_role_object['Credentials']
    return credentials

def assume_role_service_resource(role_arn, service_id, region):
    credentials = assumeCredentials(service_id, role_arn)
    return boto3.resource(
            service_id,
            region_name = region,
            aws_access_key_id=credentials['AccessKeyId'],
            aws_secret_access_key=credentials['SecretAccessKey'],
            aws_session_token=credentials['SessionToken']
            )

def assume_role_service_client(role_arn, service_id, region):
    credentials = assumeCredentials(service_id, role_arn)
    return boto3.client(
            service_id,
            region_name = region,
            aws_access_key_id=credentials['AccessKeyId'],
            aws_secret_access_key=credentials['SecretAccessKey'],
            aws_session_token=credentials['SessionToken']
            )

def list_s3_buckets(s3):
    buckets = s3.buckets.all()
    return buckets

def evaluate_s3_bucket_tags(buckets, s3, s3_client):
    bucketlist = []
    for bucket in buckets:
        bucket = str(bucket).split("'")
        bucket = str(bucket[1])
        try:
            response = s3_client.get_bucket_tagging(Bucket=bucket)
            for branch in response:
                # print(branch)
                if branch == "TagSet":
                    tags = response[branch]
                    if BackupString in str(tags):
                        print("")
                    elif NoBackupString in str(tags):
                        print("")
                    else:
                        bucketlist.append(bucket)
        except ClientError:
            bucketlist.append(bucket)
    return bucketlist

def s3_set_backup_tags(bucketlist, s3):
    for bucket in bucketlist:
        print(bucket)
        bucket_tagging = s3.BucketTagging(bucket)
        print(bucket_tagging)
        tags = bucket_tagging.tag_set
        print(tags)
        tags.append({'Key':'BackupEnabled', 'Value': 'True'})
        bucket_tagging.put(Tagging={'TagSet':tags})


        

def lambda_handler(event, context):
    init_conf()
    s3 = assume_role_service_resource(arn, "s3", region)
    s3_client = assume_role_service_client(arn, "s3", region)
    buckets = list_s3_buckets(s3)
    bucketlist = evaluate_s3_bucket_tags(buckets, s3, s3_client)
    # print(bucketlist)
    s3_set_backup_tags(bucketlist, s3)
    return {
        'statusCode': 200,
        'body': "OK"
    }


lambda_handler("", "")
