> START INSTRUCTION FOR TECHNATIVE ENGINEERS

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


# Terraform AWS [Module Name] ![](https://img.shields.io/github/workflow/status/TechNative-B-V/terraform-aws-module-name/Lint?style=plastic)

<!-- SHIELDS -->

This module implements ...

[![](we-are-technative.png)](https://www.technative.nl)

## How does it work

### Requirements

This module requires at least the following Terraform configuration on the management account.

```ruby
resource "aws_organizations_organization" "this" {
  aws_service_access_principals = [ "backup.amazonaws.com" ]

  enabled_policy_types = [ "BACKUP_POLICY" ]
}
```

When `enable_external_vault` is `true` then make sure that the provider `aws.external_vault` is set and from the *same* region as the AWS account.

When the `backup_vault_kms_key_arn` is in another account make sure that any providers that create vaults have access to this KMS key. Required permissions:
- kms:CreateGrant
- kms:GenerateDataKey
- kms:Decrypt
- kms:RetireGrant
- kms:DescribeKey

This requirement can be automated once Terraform `aws_kms_grant` supports service principals. See [issue 13994](https://github.com/hashicorp/terraform-provider-aws/issues/13994) for this (please upvote!).

All accounts with vaults must have the `AWSServiceRoleForBackup` service linked role. This can be created in Terraform with:

```ruby
resource "aws_iam_service_linked_role" "backup_service_linked_role" {
  aws_service_name = "backup.amazonaws.com"
}
```

This modules requires KMS access for the role `role/aws-service-role/backup.amazonaws.com/AWSServiceRoleForBackup`. Our KMS key has these policies.

### Known issues

Initial creation could results in errors like below. Retry again to resolve.

╷
│ Error: error creating Backup Vault Lock Configuration (name): AccessDeniedException: 
│       status code: 403, request id: 44cfe1e4-7aab-4c95-b142-9e600b278916
│ 
│   with module.organization_backup.module.backup_vault_external[0].aws_backup_vault_lock_configuration.this,
│   on modules/aws-organization-backup/backup_vault/main.tf line 10, in resource "aws_backup_vault_lock_configuration" "this":
│   10: resource "aws_backup_vault_lock_configuration" "this" {
│ 
╵

## Usage

To use this module ...

```hcl
{
  some_conf = "might need explanation"
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
