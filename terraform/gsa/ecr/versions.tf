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
  region = "us-east-1"
  allowed_account_ids = ["898673322888"]
}
