terraform {
  backend "s3" {
    bucket         = "sba-ckan-terraform-remote-state"
    key            = "gsa-ckan-ecr.tfstate"
    workspace_key_prefix = "gsa-ecr"
    region         = "us-east-1"
    dynamodb_table = "sba-ckan-terraform-state-locktable"
    acl            = "bucket-owner-full-control"
  }
}
