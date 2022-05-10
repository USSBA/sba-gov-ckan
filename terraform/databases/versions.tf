terraform {
  required_providers {
    aws = {
      version = "~> 4.1, < 5.0"
      source  = "hashicorp/aws"
    }
  }
  required_version = "~> 1.0"
}
provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["230968663929"]
  default_tags {
    tags = {
      Environment     = terraform.workspace
      TerraformSource = "sba-gov-ckan/terraform/databases"
      ManagedBy       = "terraform"
    }
  }
}
terraform {
  backend "s3" {
    bucket         = "sbagovlower-terraform-remote-state"
    key            = "ckan-databases.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locktable"
    acl            = "bucket-owner-full-control"
  }
}
