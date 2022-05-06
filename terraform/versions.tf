terraform {
  required_providers {
    aws = {
      version = "~> 3.0"
      source  = "hashicorp/aws"
    }
  }
  required_version = ">= 0.13"
}
provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["230968663929"]
}
terraform {
  backend "s3" {
    bucket         = "sbagovlower-terraform-remote-state"
    key            = "ckan.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locktable"
    acl            = "bucket-owner-full-control"
  }
}
