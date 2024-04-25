variable "name" {
    description = "Name for several resources to allow this module to be reused within the same account. Must also be unique for any vaults in external accounts. Required"
    type = string
}

variable "backup_vault_kms_key_arn" {
    description = "Backup vault KMS key ARN to be used for internal and optional external vault. Required."
    type = string
}

variable "enable_external_vault" {
    description = "This will create a mimic vault in the account provided by `aws.external_vault`. If set to false then `aws.external_vault` can be set to any account as it's not used."
    type = bool
}

variable "external_backup_vault_kms_key_arn" {
    description = "External backup vault KMS key ARN to be used for external vault. If not set then value taken from `var.backup_vault_kms_key_arn` is used. This variable must be set to support cross-region setups."
    type = string
    default = null
}

variable "immutable_vault" {
    description = "Make the local and (optional) external vault immutable to prevent deletion. Immutable vaults can never be deleted after 90 days."
    type = bool
    default = true
}
