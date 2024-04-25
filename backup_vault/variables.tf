variable "name" {
    description = "Name backup vault. Required"
    type = string
}

variable "kms_key_arn" {
    description = "Backup vault KMS key ARN to be used for internal and optional external vault. Required."
    type = string
}

variable "immutable_vault" {
    description = "Make the vault immutable to prevent deletion. Immutable vaults can never be deleted after 90 days."
    type = bool
    default = true
}
