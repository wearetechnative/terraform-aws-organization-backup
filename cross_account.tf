resource "aws_backup_global_settings" "this" {
  count = var.enable_external_vault ? 1 : 0

  provider = aws.management

  global_settings = {
    "isCrossAccountBackupEnabled" = true
  }

  lifecycle {
    prevent_destroy = true # note: isCrossAccountBackupEnabled will not revert to false upon deletion of 'Cross-account monitoring' & 'Cross-account backup' in AWS Backup -> 'Settings'
  }
}
