terraform {
  required_version = ">= 1.1.0, < 1.3.0"
  required_providers {
   aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region    = "eu-central-1"
}

locals {
}

module "backup-poc" {
  source = "./modules/backup-enforcer"
}

module "backup_policy" {
  source = "./modules/backup-policy"
}