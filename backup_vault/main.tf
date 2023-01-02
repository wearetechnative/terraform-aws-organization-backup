resource "aws_backup_vault" "this" {
  name        = var.name
  kms_key_arn = var.kms_key_arn

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_backup_vault_lock_configuration" "this" {
  backup_vault_name   = var.name
  changeable_for_days = !var.immutable_vault ? null : 90
  max_retention_days  = 1200
  min_retention_days  = 7
}
