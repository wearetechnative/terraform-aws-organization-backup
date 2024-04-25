data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_caller_identity" "external_vault" {
    provider = aws.external_vault
}
data "aws_default_tags" "current" {}
