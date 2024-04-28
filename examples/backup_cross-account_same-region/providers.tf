provider "aws" {
  region              = "eu-central-1"
  allowed_account_ids = ["xxxxxxxxx"]

  assume_role {
    role_arn     = "arn:aws:iam::xxxxxxxxx:role/xxxxxxxxx"
    session_name = "terraform_state_update"
  }

  default_tags {
    tags = {
      Createdby   = "Terraform"
      Developer   = "Andrew"
      IaC_Project = "aws_backup_test"
    }
  }
}

provider "aws" {
  region              = "eu-central-1"
  allowed_account_ids = ["xxxxxxxxx"]

  alias = "management"

  assume_role {
    role_arn     = "arn:aws:iam::xxxxxxxxx:role/xxxxxxxxx"
    session_name = "terraform_state_update"
  }

  default_tags {
    tags = {
      Createdby   = "Terraform"
      Developer   = "Andrew"
      IaC_Project = "aws_backup_test"
    }
  }
}

provider "aws" {
  region              = "eu-central-1"
  allowed_account_ids = ["xxxxxxxx"]

  alias = "external_backup"

  assume_role {
    role_arn     = "arn:aws:iam::xxxxxxx:role/xxxxxxxxx"
    session_name = "terraform_state_update"
  }

  default_tags {
    tags = {
      Createdby   = "Terraform"
      Developer   = "Andrew"
      IaC_Project = "aws_backup_test"
    }
  }
}