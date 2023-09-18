terraform {
  backend "s3" {
    bucket         = "sba-ckan-terraform-remote-state"
    key            = "ckan-ecr.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sba-ckan-terraform-state-locktable"
    acl            = "bucket-owner-full-control"
  }
}
