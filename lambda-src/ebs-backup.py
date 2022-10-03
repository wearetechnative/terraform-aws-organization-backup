import boto3
import os
from botocore.exceptions import ClientError

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

def list_ebs_volumes(ec2):
    volumes = ec2.volumes.all()
    return volumes

def evaluate_ebs_volume_tags(volumes, ec2):
    volumelist = []
    for volume in volumes:
        volume = str(volume).split("'")
        volume = str(volume[1])
        volInfo = ec2.Volume(id=volume)
        hasBackupTag = False
        if volInfo.tags != None:
            for tag in volInfo.tags:
                if tag['Key'] == 'BackupEnabled':
                    if tag['Value'] == 'True':
                        hasBackupTag = True
                    elif tag['Value'] == 'False':
                        hasBackupTag = True
        else:
            hasBackupTag == False

        if hasBackupTag == False:
            volumelist.append(volume)
    return volumelist

def ebs_set_backup_tags(volumelist, ec2):
    if volumelist != []: 
        ec2.create_tags(
            Resources = volumelist,
            Tags = [{
                'Key': 'BackupEnabled',
                'Value': 'True'
            },
            ]
        )

def lambda_handler(event, context):
    init_conf()
    ec2 = assume_role_service_resource(arn, "ec2", region)
    volumes = list_ebs_volumes(ec2)
    volumelist = evaluate_ebs_volume_tags(volumes, ec2)
    ebs_set_backup_tags(volumelist, ec2)
    return {
        'statusCode': 200,
        'body': "OK"
    }
