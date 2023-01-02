terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">4.27" # https://github.com/hashicorp/terraform-provider-aws/issues/25977

      configuration_aliases = [aws, aws.management, aws.external_vault]
    }
  }
}
