> START INSTRUCTION FOR TECHNATIVE ENGINEERS

TODO: Implement remainder of these instructions in Github. Keep instructions here to make sure they are being processed someday.
- Most of the data is here but I need to go through all of it again.
- We are still developing it for other customers, so keep it private for now.

# terraform-aws-module-template

Template for creating a new TerraForm AWS Module. For TechNative Engineers.

## Instructions

### Your Module Name

Think hard and come up with the shortest descriptive name for your module.
Look at competition in the [terraform
registry](https://registry.terraform.io/).

Your module name should be max. three words seperated by dashes. E.g.

- html-form-action
- new-account-notifier
- budget-alarms
- fix-missing-tags

### Setup Github Project

1. Click the template button on the top right...
1. Name github project `terraform-aws-[your-module-name]`
1. Make project private untill ready for publication
1. Add a description in the `About` section (top right)
1. Add tags: `terraform`, `terraform-module`, `aws` and more tags relevant to your project: e.g. `s3`, `lambda`, `sso`, etc..
1. Install `pre-commit`

### Develop your module

1. Develop your module
1. Try to use the [best practices for TerraForm
   development](https://www.terraform-best-practices.com/) and [TerraForm AWS
   Development](https://github.com/ozbillwang/terraform-best-practices).

## Finish project documentation

1. Set well written title
2. Add one or more shields
3. Start readme with a short and complete as possible module description. This
   is the part where you sell your module.
4. Complete README with well written documentation. Try to think as a someone
   with three months of Terraform experience.
5. Check if pre-commit correctly generates the standard Terraform documentation.

## Publish module

If your module is in a state that it could be useful for others and ready for
publication, you can publish a first version.

1. Create a [Github
   Release](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases)
2. Publish in the TerraForm Registry under the Technative Namespace (the GitHub
   Repo must be in the TechNative Organization)

---

> END INSTRUCTION FOR TECHNATIVE ENGINEERS


# Terraform AWS [aws-organization-backup]

<!-- SHIELDS -->

This module implements a standard `AWS Backup` setup using `AWS Organizaion` backup policies for enforcement.

The module is currently tested for single vault and cross-account same region setups only. Cross-account and cross-region should be easy to implement.

[![](we-are-technative.png)](https://www.technative.nl)

## How does it work

### Known (major) limitations

Currently only tested and developed on cross-account within the same region or single vault setups. Cross-account and cross-region combined should be possible as well but needs testing / more work.

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

### Known issues

Initial creation could results in errors like below. Retry again to resolve.

\╷
\│ Error: error creating Backup Vault Lock Configuration (name): AccessDeniedException: 
\│       status code: 403, request id: 44cfe1e4-7aab-4c95-b142-9e600b278916
\│ 
\│   with module.organization_backup.module.backup_vault_external[0].aws_backup_vault_lock_configuration.this,
\│   on modules/aws-organization-backup/backup_vault/main.tf line 10, in resource "aws_backup_vault_lock_configuration" "this":
\│   10: resource "aws_backup_vault_lock_configuration" "this" {
\│ 
\╵

Sometimes it looks like AWS Backup is not working but it simply could take hours(!) before something happens.

Enable AWS EventBridge rules on `aws.backup` to closely monitor events and issues since you can also see CloudTrail events.

## Usage

To use this module see the ./examples directory for the 2 main workflows. External vault indicates a cross-account setup only.

*ALWAYS* make sure you see your resources in 'Protected Resources' before assuming that the backup plan is correctly configured.

## Future work

- Combined cross-account and cross-region. Probably requires seperate KMS keys.
- Automatic handling of setting up KMS access under different configurations (e.g. KMS per vault location, KMS shared in source vault account, KMS shared in destination vault account).

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
