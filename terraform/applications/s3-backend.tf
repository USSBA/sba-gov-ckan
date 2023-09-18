terraform {
  backend "s3" {
    bucket         = "sba-ckan-terraform-remote-state"
    key            = "ckan.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sba-ckan-terraform-state-locktable"
    acl            = "bucket-owner-full-control"
  }
}

# Leaving commented out until the migration is complete so we can swap back and forth in states if needed.
#terraform {
#  backend "s3" {
#    bucket         = "sbagovlower-terraform-remote-state"
#    key            = "ckan.tfstate"
#    region         = "us-east-1"
#    dynamodb_table = "terraform-state-locktable"
#    acl            = "bucket-owner-full-control"
#  }
#}
