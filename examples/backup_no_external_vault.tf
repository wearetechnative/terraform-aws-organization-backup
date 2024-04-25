# no external vault (so aws.external_vault can be set to any provider)
# KMS key in same account with local vault
# no additional KMS policy needed to setup

module "organization_backup" {
  providers = {
    aws = aws
    aws.management = aws.management
    aws.external_vault = aws # not needed since enable_external_vault set false
   }

  source = "./modules/aws-organization-backup"

  name = "<customer>"
  backup_vault_kms_key_arn = module.kms_backup_vault.kms_key_arn
  enable_external_vault = false
  immutable_vault = true
}

resource "aws_iam_service_linked_role" "backup_service_linked_role" {
  aws_service_name = "backup.amazonaws.com" # creates AWSServiceRoleForBackup
}

module "kms_backup_vault" {
  # source = "git@github.com:TechNative-B-V/modules-aws.git//kms?ref=61e551bab2bc56a134b57365dcc8670f362881ce"
  source = "./modules/kms"

  providers = {
    aws = aws
   }

  name = "<customer>_backup_vault"
}
