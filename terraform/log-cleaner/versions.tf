terraform {
  required_version = "1.6.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = [local.all[terraform.workspace].account_id]
  default_tags {
    tags = {
      TerraformSource = "sba-gov-ckan/terraform/log-cleaner"
      ManagedBy       = "terraform"
    }
  }
}
terraform {
  backend "s3" {
    bucket               = "sba-ckan-terraform-remote-state"
    region               = "us-east-1"
    dynamodb_table       = "sba-ckan-terraform-state-locktable"
    acl                  = "bucket-owner-full-control"
    key                  = "log-cleaner.terraform.tfstate"
    workspace_key_prefix = "log-cleaner"
  }
}
