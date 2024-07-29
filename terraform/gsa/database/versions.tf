terraform {
  required_providers {
    aws = {
      version = "~> 5.0"
      source  = "hashicorp/aws"
    }
  }
  required_version = "1.6.1"
}

provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["898673322888"]
  default_tags {
    tags = {
      Environment     = terraform.workspace
      TerraformSource = "sba-gov-ckan/terraform/gsa/database"
      ManagedBy       = "terraform"
    }
  }
}

terraform {
  backend "s3" {
    bucket               = "sba-ckan-terraform-remote-state"
    key                  = "gsa-database.tfstate"
    workspace_key_prefix = "gsa-database"
    region               = "us-east-1"
    dynamodb_table       = "sba-ckan-terraform-state-locktable"
    acl                  = "bucket-owner-full-control"
  }
}
