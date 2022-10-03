import boto3
from botocore.exceptions import ClientError

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

def list_volumes(ec2):
    volumes = ec2.volumes.all()
    return volumes

def eval_volumes(volumes, ec2):
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
        else:
            hasBackupTag == False

        if hasBackupTag == False:
            volumelist.append(volume)
    return volumelist

def set_tags(volumelist, ec2):
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
    arn = 'arn:aws:iam::444650676521:role/OrganizationAccountAccessRole'
    ec2 = assume_role_service_resource(arn, "ec2", "eu-west-1")
    volumes = list_volumes(ec2)
    volumelist = eval_volumes(volumes, ec2)
    set_tags(volumelist, ec2)
    return {
        'statusCode': 200,
        'body': "OK"
    }
