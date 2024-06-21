terraform {
  backend "s3" {
    bucket               = "sba-ckan-terraform-remote-state"
    key                  = "gsa-network.tfstate"
    workspace_key_prefix = "gsa-network"
    region               = "us-east-1"
    dynamodb_table       = "sba-ckan-terraform-state-locktable"
    acl                  = "bucket-owner-full-control"
  }
}
