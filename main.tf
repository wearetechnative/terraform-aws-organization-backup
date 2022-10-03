terraform {
  required_version = ">= 1.1.0, < 1.3.0"
  required_providers {
   aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Create KMS Key for vault:
resource "aws_kms_key" "createKmsKey" {
  description = "AWS BackUp KMS key"
}

# Create a vault for the backup
resource "aws_backup_vault" "backupVaultSetup" {
  name = "prod_backup_vault"
  #KMS key selection:
  kms_key_arn = aws_kms_key.createKmsKey.arn
# Prevents destruction of vault (!!!ENABLE LATER!!!) (DISABLED FOR TESTING)
#   lifecycle {
#     prevent_destroy = true
# } 
}

data "template_file" "backup_policy" {
    template = file("./policies/backup-policy.json")
    vars = {
        VAULT1 = aws_backup_vault.backupVaultSetup.name
    }
}

resource "aws_organizations_policy" "setBackupPolicy" {
  name = "BackupPolicy"
  type = "BACKUP_POLICY"

  content = "${data.template_file.backup_policy.rendered}"
}

resource "aws_organizations_policy_attachment" "applyBackupPolicy" {
  policy_id = aws_organizations_policy.setBackupPolicy.id
  target_id = "ou-q6tq-3nf7l5qz"
  # ⬆️⬆️⬆️ Our organization ID ⬆️⬆️⬆️
}

module "erfgeo_lambda" {
  source = "terraform-aws-modules/lambda/aws"
  version = "3.3.1"

  function_name = "erefgeo-backup-policy-enforcer"
  description   = "Set appropriate backup tags on erfgeo resources"
  handler       = "ebs-backup.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60

  source_path =  "./lambda-src/ebs-backup.py"

  publish = true
  allowed_triggers = {
  }

  environment_variables = {
    ROLEARN = "444650676521"
    REGION = "eu-west-1"
  }
  attach_policy_json = true
  policy_json = data.aws_iam_policy_document.lambda_extra_permissions.json
}

# lambda permissions

data "aws_iam_policy_document" "lambda_extra_permissions" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

# Cloudwatch Events (EventBridge)

# !!!TURNED OFF FOR TESTING!!!

# resource "aws_cloudwatch_event_rule" "trigger_lambda" {
#   schedule_expression = "rate(1 day)"
# }

# resource "aws_cloudwatch_event_target" "lambda_target" {
#   rule = "${aws_cloudwatch_event_rule.trigger_lambda.name}"
#   arn  = module.erfgeo_lambda.lambda_function_arn
# }
