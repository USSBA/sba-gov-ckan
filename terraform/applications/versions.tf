terraform {
  required_providers {
    aws = {
      version = "~> 4.0, < 5.0"
      source  = "hashicorp/aws"
    }
  }
  required_version = "~> 1.0"
}
provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["898673322888"]
}
