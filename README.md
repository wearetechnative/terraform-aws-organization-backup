# Terraform AWS [aws-organization-backup]

<!-- SHIELDS -->

This module implements a standard `AWS Backup` setup using `AWS Organizaion` backup policies for enforcement.

The module is currently tested for single vault and cross-account same region setups only. Cross-account and cross-region should be easy to implement.

[![](we-are-technative.png)](https://www.technative.nl)

## How does it work

AWS Backup works by copying targeted resource's data into s3 storage on a schedule.
You can select which resources you want to back up with the use of tags. (explained further in ./plan.md).
The data can be backed up to other regions or AWS accounts.
AWS Backup integrates with other AWS services, such as AWS Identity and Access Management (IAM) for authentication and Amazon CloudWatch for logging and monitoring.

### Known (major) limitations

Currently only tested and developed on cross-account within the same region or single vault setups. Cross-account and cross-region combined should be possible as well but needs testing / more work.

### Requirements

- This module requires at least the following Terraform configuration on the management account.

```json
resource "aws_organizations_organization" "this" {
  aws_service_access_principals = [ "backup.amazonaws.com" ]

  enabled_policy_types = [ "BACKUP_POLICY" ]
}
```

- When `enable_external_vault` is `true` then make sure that the provider `aws.external_vault` is set and from the *same* region as the AWS account.

- When the `backup_vault_kms_key_arn` is in another account make sure that any providers that create vaults have access to this KMS key. Required permissions:
  - kms:CreateGrant
  - kms:GenerateDataKey
  - kms:Decrypt
  - kms:RetireGrant
  - kms:DescribeKey

This requirement can be automated once Terraform `aws_kms_grant` supports service principals. See [issue 13994](https://github.com/hashicorp/terraform-provider-aws/issues/13994) for this (please upvote!).

- All accounts with vaults must have the `AWSServiceRoleForBackup` service linked role. This can be created / imported in Terraform with:

```json
resource "aws_iam_service_linked_role" "backup_service_linked_role" {
  aws_service_name = "backup.amazonaws.com"
}
```

- This modules requires KMS access for the role `role/aws-service-role/backup.amazonaws.com/AWSServiceRoleForBackup`. Our [KMS key module](https://github.com/TechNative-B-V/modules-aws/commit/9f5d80f00cc477ba57d95b26230913f685e0fae9) has these policies.

- Enable all resources for *each region* in the *management account* to make sure that resources are included.

```json
resource "aws_backup_region_settings" "this" {
  resource_type_opt_in_preference = {
    "Aurora" = true,
    "CloudFormation" = true,
    "DocumentDB" = true,
    "DynamoDB" = true,
    "EBS" = true,
    "EC2" = true,
    "EFS" = true,
    "FSx" = true,
    "Neptune" = true,
    "RDS" = true,
    "Redshift" = true,
    "S3" = true,
    "Storage Gateway" = true,
    "Timestream" = true,
    "VirtualMachine" = true
  }

  resource_type_management_preference = {
    "DynamoDB" = true
    "EFS"      = true
  }
}
```

### Known issues

Initial creation could results in errors like below. Retry again to resolve.

╷\
│ Error: error creating Backup Vault Lock Configuration (name): AccessDeniedException:\
│       status code: 403, request id: 44cfe1e4-7aab-4c95-b142-9e600b278916\
│\
│   with module.organization_backup.module.backup_vault_external[0].aws_backup_vault_lock_configuration.this,\
│   on modules/aws-organization-backup/backup_vault/main.tf line 10, in resource "aws_backup_vault_lock_configuration" "this":\
│   10: resource "aws_backup_vault_lock_configuration" "this" {\
│\
╵

Sometimes it looks like AWS Backup is not working but it simply could take hours(!) before something happens.

Enable AWS EventBridge rules on `aws.backup` to closely monitor events and issues since you can also see CloudTrail events.

## Usage

To use this module see the ./examples directory for the 2 main workflows. External vault indicates a cross-account setup only.

*ALWAYS* make sure you see your resources in 'Protected Resources' before assuming that the backup plan is correctly configured.

## Future work

- Combined cross-account and cross-region. Probably requires seperate KMS keys.
- Automatic handling of setting up KMS access under different configurations (e.g. KMS per vault location, KMS shared in source vault account, KMS shared in destination vault account).
