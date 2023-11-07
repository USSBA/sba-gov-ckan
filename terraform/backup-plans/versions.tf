provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["898673322888"]
  default_tags {
    tags = {
      Environment     = terraform.workspace
      ManagedBy       = "terraform"
      TerraformSource = "sba-gov-ckan/terraform/backup-plans"
    }
  }
}
terraform {
  backend "s3" {
    bucket               = "sba-ckan-terraform-remote-state"
    dynamodb_table       = "sba-ckan-terraform-state-locktable"
    acl                  = "bucket-owner-full-control"
    key                  = "backup-plans.tfstate"
    region               = "us-east-1"
    workspace_key_prefix = "backup-plans"
  }
  required_version = "~> 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
