# backup anything tagged as BackupEnabled = True
# use KMS from external account with external vault located at aws.external_backup
# requires additional KMS policy needed to setup

module "organization_backup" {
  providers = {
    aws = aws
    aws.management = aws.management
    aws.external_vault = aws.external_backup
   }

  source = "./modules/aws-organization-backup"

  name = "<customer>"
  backup_vault_kms_key_arn = module.kms_backup_vault.kms_key_arn
  enable_external_vault = true
  immutable_vault = true
}

resource "aws_iam_service_linked_role" "backup_service_linked_role" {
  aws_service_name = "backup.amazonaws.com" # creates AWSServiceRoleForBackup
}

module "kms_backup_vault" {
  # source = "git@github.com:TechNative-B-V/modules-aws.git//kms?ref=61e551bab2bc56a134b57365dcc8670f362881ce"
  source = "./modules/kms"

  providers = {
    aws = aws.external_backup
   }

  name = "<customer>_backup_vault"
  resource_policy_additions = jsondecode(data.aws_iam_policy_document.backup_vault_kms_external_account.json)
}

# this policy is required so Terraform can set the proper grants on the KMS
data "aws_iam_policy_document" "backup_vault_kms_external_account" {
  statement {
    sid = "Allow <customer> OrganizationAccountAccessRole to setup KMS key for AWS Backup Vault using external KMS key."

    actions = [
      "kms:CreateGrant", "kms:GenerateDataKey", "kms:Decrypt", "kms:RetireGrant", "kms:DescribeKey"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123123123:role/OrganizationAccountAccessRole"] # hardcoded since we cannot derive right now :(
    }

    resources = ["*"]
  }
}
