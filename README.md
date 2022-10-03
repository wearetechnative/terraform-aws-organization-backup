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

## s3-backup.py

## 
## main.tf

> using aws version ~> 4.0

Uses the management account to upload the policy & lambda functions to our organization

usage:
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
    ROLEARN = "{ACCOUNT ARN}"
    REGION = "{REGION}" 
  }
  attach_policy_json = true
  policy_json = data.aws_iam_policy_document.lambda_extra_permissions.json
}

```

current variables:

- ROLEARN

- REGION
