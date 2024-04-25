module "backup_vault" {
  source = "./backup_vault"

  providers = {
    aws = aws
   }

  name = var.name
  kms_key_arn = var.backup_vault_kms_key_arn
  immutable_vault = var.immutable_vault
}

locals {
  external_backup_vault_kms_key_arn = var.external_backup_vault_kms_key_arn != null ? var.external_backup_vault_kms_key_arn : var.backup_vault_kms_key_arn
}

module "backup_vault_external" {
  count = var.enable_external_vault ? 1 : 0

  providers = {
    aws = aws.external_vault
  }

  source = "./backup_vault"

  name = var.name
  kms_key_arn = local.external_backup_vault_kms_key_arn
  immutable_vault = var.immutable_vault
}

resource "aws_kms_grant" "kms_grant_external_vault" {
  count = var.enable_external_vault && split(":", local.external_backup_vault_kms_key_arn)[4] == data.aws_caller_identity.external_vault.account_id ? 1 : 0

  provider = aws.external_vault

  name              = "aws_backup_${var.name}_external_vault_kms"
  key_id            = var.external_backup_vault_kms_key_arn
  grantee_principal = module.iam_role.role_arn

  # todo: probably needs less encrypt privileges but takes time to test
  operations = ["Decrypt", "Encrypt", "GenerateDataKey", "GenerateDataKeyWithoutPlaintext", "ReEncryptFrom", "ReEncryptTo", "CreateGrant", "RetireGrant", "DescribeKey", "GenerateDataKeyPair", "GenerateDataKeyPairWithoutPlaintext"]
}

resource "aws_backup_vault_policy" "source_account_to_destination_account_vault_access" {
  count = var.enable_external_vault ? 1 : 0

  provider = aws.external_vault

  backup_vault_name = module.backup_vault_external[0].backup_vault_name

  policy = data.aws_iam_policy_document.source_account_to_destination_account_vault_access.json
}

data "aws_iam_policy_document" "source_account_to_destination_account_vault_access" {
  statement {
    sid = "Allow source account to access destination account vault."

    actions = [ "backup:CopyIntoBackupVault" ]

    principals {
      type        = "AWS"
      identifiers = [module.iam_role.role_arn]
    }

    resources = ["*"]
  }
}

resource "aws_organizations_policy" "this" {
  provider = aws.management
  
  name = var.name
  type = "BACKUP_POLICY"

  content = jsonencode(local.default_plan)
}

resource "aws_organizations_policy_attachment" "this" {
  provider = aws.management
  
  policy_id = aws_organizations_policy.this.id
  target_id = data.aws_caller_identity.current.account_id
}
