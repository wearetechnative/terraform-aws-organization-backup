# replaces AWSBackupDefaultServiceRole
module "iam_role" {
  source = "github.com/wearetechnative/terraform-aws-iam-role.git?ref=9229bbd0280807cbc49f194ff6d2741265dc108a"

  role_name = "AWSBackup_${var.name}"
  role_path = "/AWSBackup/"

  aws_managed_policies = ["AWSBackupServiceRolePolicyForBackup", "AWSBackupServiceRolePolicyForRestores", "AWSBackupServiceRolePolicyForS3Backup", "AWSBackupServiceRolePolicyForS3Restore"]

  trust_relationship = {
    "backup" : { "identifier" : "backup.amazonaws.com", "identifier_type" : "Service", "enforce_mfa" : false, "enforce_userprincipal" : false, "external_id" : null, "prevent_account_confuseddeputy" : false }
  }
}
