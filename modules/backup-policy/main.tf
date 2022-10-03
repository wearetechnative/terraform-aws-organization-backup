
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
    template = "${file("${path.module}/templates/backup-policy.json")}"
    vars = {
        VAULT1 = aws_backup_vault.backupVaultSetup.name
    }
}

resource "aws_organizations_policy" "setBackupPolicy" {
  name = "POCBackupPolicy"
  type = "BACKUP_POLICY"

  content = "${data.template_file.backup_policy.rendered}"
}

resource "aws_organizations_policy_attachment" "applyBackupPolicy" {
  policy_id = aws_organizations_policy.setBackupPolicy.id
  target_id = "ou-q6tq-3nf7l5qz"
}