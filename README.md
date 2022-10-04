# AWS Organization BackUp repo

## use this script in combination with `export AWS_PROFILE={technative management role name }` to upload the code to the management account

> use the name you have set in ~/.aws/config

AWS Organization BackUp repository

__

## backup-policy.json

Our backup policy currently has 1 backup rule.

The policy targets all resources with the tag `BackupEnabled: True` within the sandbox organization unit.

It backs up all targeted resources everyday and keeps the backups for 1 month (28 days) before it deletes.

The backup gets initiated at 7 am UTC everyday 

>⚠️WARNING⚠️ **This does not mean it will be backup up at that time backups can take 60-1440 minutes to take effect**

the backup will be saved in the PRODVAULT on the management account

## ebs-backup.py

### lambda_handler()

initiates the lambda function

### init_conf()

makes sure the `arn` and `region` are properly imported and formatted


### assume_role_service_resource()

Changes role to the correct account, resource & region, and returns the client/resource


### list_ebs_volumes()

makes a list of all EBS volumes in selected accounts region 

###  evaluate_ebs_volume_tags()

Parses the name of all EBS resources so it can work with boto 3.

then checks if it already has a BackupEnabled True/False tag if it doesnt it will be added to `volumelist`

### ebs_set_backup_tags

takes the `volumelist` array and adds the tag BackupEnabled: True to all EBS resources listed

## s3-backup.py

### init_conf()

makes sure the `arn` and `region` are properly imported and formatted

### assume_role_service_resource()

Changes role to the correct account, resource & region, and returns the client/resource

### assume_role_service_client()

Changes role to the correct account, resource & region, and returns the client/resource


### list_s3_buckets()

makes a list of all S3 volumes in selected accounts region 

### evaluate_s3_backup_tags()

Parses the name of all S3 resources so it can work with boto3.

It will scans all tagging information for resource tags.

Then it will go over all resource tags and checks if it has a `BackupEnabled: True/False` tag

All resources without the `BackupEnabled: True/False` tag will be added to `bucketlist`

### ebs_set_backup_tags

takes the `bucketlist` array and appends the tag BackupEnabled: True to all S3 resources listed within the array

## main.tf

> using aws version ~> 4.0

Uses the management account to upload the policy & lambda functions to our organization

Add resource type to an account:

```tf

module "{MODULE_NAME}" {
  source = "terraform-aws-modules/lambda/aws"
  version = "3.3.1"

  function_name = "{ACCOUNT + RESOURCE TYPE}-backup-policy-enforcer"
  description   = "Set appropriate backup tags on {ACCOUNT + RESOURCE TYPE} resources"
  handler       = "{MODULE_NAME}.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60

  source_path =  "./lambda-src/{LAMBDA_MODULE}.py"

  publish = true
  allowed_triggers = {
  }

  environment_variables = {
    ROLEARN = "{ACCOUNT ID}"
    REGION = "{REGION}" 
  }
  attach_policy_json = true
  policy_json = data.aws_iam_policy_document.lambda_extra_permissions.json
}

current variables:

- ROLEARN, Needs the account id and will automatically be parsed into a usable ARN

- REGION, Specifies in which region the lambda will target

Lambda only requires the STS.AssumeRole.* permission, all action will be done on the target account

Increase time out incase lambda runs out of time

___

