# Terraform AWS [aws-organization-backup]

<!-- SHIELDS -->

This module implements a standard `AWS Backup` setup using `AWS Organizaion` backup policies for enforcement.

Any supported and enabled resource with tag `BackupEnabled` and value `True` will be included.

The module is currently tested for all scenarios except cross-region and cross-account combined. This probably just works or should be easy to implement.

*** Make sure you GUARD or BACKUP your `KMS CMK` keys as `AWS Backup` mostly uses the [original resource KMS CMK key](https://docs.aws.amazon.com/aws-backup/latest/devguide/encryption.html) for encrypting the backups. The best approach is to block `kms:ScheduleKeyDeletion` in an SCP.

Simultaneous cross-region and cross-account is [not supported](https://docs.aws.amazon.com/aws-backup/latest/devguide/whatisbackup.html#features-by-resource) for RDS, Aurora, Neptune and DocumentDB.

[![](we-are-technative.png)](https://www.technative.nl)

## How does it work

### Known (major) limitations

The module is currently tested for all scenarios except cross-region and cross-account combined. This probably just works or should be easy to implement.

### Requirements

- This module requires at least the following Terraform configuration on the management account.

```ruby
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

```ruby
resource "aws_iam_service_linked_role" "backup_service_linked_role" {
  aws_service_name = "backup.amazonaws.com"
}
```

- This modules requires KMS access for the role `role/aws-service-role/backup.amazonaws.com/AWSServiceRoleForBackup`. Our [KMS key module](https://github.com/TechNative-B-V/modules-aws/commit/9f5d80f00cc477ba57d95b26230913f685e0fae9) has these policies.

- Enable all resources for *each region* in the *management account* to make sure that resources are included.

```ruby
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

- S3 buckets with KMS encrypted objects require that the backup role outputed with `backup_role_arn` have Decrypt, DescribeKey permissions on the KMS key.

Example below with KMS grant.

```ruby
resource "aws_kms_grant" "s3_appdata" {
  name              = "aws_backup_${var.name}_s3_appdata"
  key_id            = data.terraform_remote_state.ddgcstack.outputs.ddgcstack_kms_key_arn
  grantee_principal = module.organization_backup.backup_role_arn
  operations        = ["Decrypt", "DescribeKey"]
}
```

- RDS instances with KMS encrypted snapshots require that the backup role outputed with `backup_role_arn` have DescribeKey, Decrypt, ReEncryptFrom, ReEncryptTo, CreateGrant, RetireGrant permissions on the KMS key.

```ruby
resource "aws_kms_grant" "s3_appdata" {
  name              = "aws_backup_${var.name}_s3_appdata"
  key_id            = data.terraform_remote_state.ddgcstack.outputs.ddgcstack_kms_key_arn
  grantee_principal = module.organization_backup.backup_role_arn

  operations        = ["DescribeKey", "Decrypt", "ReEncryptFrom", "ReEncryptTo", "CreateGrant", "RetireGrant"]
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

Enable AWS EventBridge rules on `aws.backup` to closely monitor events and issues since you can also see CloudTrail events. These events also tend to happen long before anything is visible in the web console.

## Usage

To use this module see the ./examples directory for the 3 main supported and tested workflows with EBS, S3 and RDS.

*ALWAYS* make sure you see your resources in 'Protected Resources' before assuming that the backup plan is correctly configured.

## Future work

- Combined  cross-account and cross-region. Probably requires seperate KMS keys.
- Automatic handling of setting up KMS access under different configurations (e.g. KMS per vault location, KMS shared in source vault account, KMS shared in destination vault account).

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >4.27 |
| <a name="provider_aws.external_vault"></a> [aws.external\_vault](#provider\_aws.external\_vault) | >4.27 |
| <a name="provider_aws.management"></a> [aws.management](#provider\_aws.management) | >4.27 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backup_vault"></a> [backup\_vault](#module\_backup\_vault) | ./backup_vault | n/a |
| <a name="module_backup_vault_external"></a> [backup\_vault\_external](#module\_backup\_vault\_external) | ./backup_vault | n/a |
| <a name="module_iam_role"></a> [iam\_role](#module\_iam\_role) | ../identity_and_access_management/iam_role/ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_backup_global_settings.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_global_settings) | resource |
| [aws_backup_vault_policy.source_account_to_destination_account_vault_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_policy) | resource |
| [aws_kms_grant.kms_grant_external_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_grant) | resource |
| [aws_organizations_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.external_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_default_tags.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.source_account_to_destination_account_vault_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_vault_kms_key_arn"></a> [backup\_vault\_kms\_key\_arn](#input\_backup\_vault\_kms\_key\_arn) | Backup vault KMS key ARN to be used for internal and optional external vault. Required. | `string` | n/a | yes |
| <a name="input_enable_external_vault"></a> [enable\_external\_vault](#input\_enable\_external\_vault) | This will create a mimic vault in the account provided by `aws.external_vault`. If set to false then `aws.external_vault` can be set to any account as it's not used. | `bool` | n/a | yes |
| <a name="input_external_backup_vault_kms_key_arn"></a> [external\_backup\_vault\_kms\_key\_arn](#input\_external\_backup\_vault\_kms\_key\_arn) | External backup vault KMS key ARN to be used for external vault. If not set then value taken from `var.backup_vault_kms_key_arn` is used. This variable must be set to support cross-region setups. | `string` | `null` | no |
| <a name="input_immutable_vault"></a> [immutable\_vault](#input\_immutable\_vault) | Make the local and (optional) external vault immutable to prevent deletion. Immutable vaults can never be deleted after 90 days. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for several resources to allow this module to be reused within the same account. Must also be unique for any vaults in external accounts. Required | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_role_arn"></a> [backup\_role\_arn](#output\_backup\_role\_arn) | n/a |
<!-- END_TF_DOCS -->
