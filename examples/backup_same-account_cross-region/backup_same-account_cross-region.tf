# backup anything tagged as BackupEnabled = True
# cross region so separate KMS keys

module "organization_backup" {
  providers = {
    aws                = aws
    aws.management     = aws.management
    aws.external_vault = aws.external_backup
  }

  source = "../../modules/aws-organization-backup"

  name                              = var.name
  backup_vault_kms_key_arn          = module.kms_backup_vault.kms_key_arn
  external_backup_vault_kms_key_arn = module.kms_backup_vault_external.kms_key_arn
  enable_external_vault             = true
  immutable_vault                   = true
}

resource "aws_iam_service_linked_role" "backup_service_linked_role" {
  aws_service_name = "backup.amazonaws.com" # creates AWSServiceRoleForBackup
}

module "kms_backup_vault" {
  source = "github.com/wearetechnative/terraform-aws-kms.git?ref=96e823e21f41ddcb29c9d9ed04a7f65e74cbac74"

  name = "${var.name}_backup_vault"
}

module "kms_backup_vault_external" {
  source = "github.com/wearetechnative/terraform-aws-kms.git?ref=96e823e21f41ddcb29c9d9ed04a7f65e74cbac74"

  providers = {
    aws = aws.external_backup
  }

  name = "${var.name}_backup_vault"
}

