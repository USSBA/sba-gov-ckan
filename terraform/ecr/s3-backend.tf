terraform {
  backend "s3" {
    bucket         = "sbagovlower-terraform-remote-state"
    key            = "ckan-ecr.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locktable"
    acl            = "bucket-owner-full-control"
  }
}
