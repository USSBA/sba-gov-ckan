module "remote-state" {
  source  = "USSBA/bootstrapper/aws"
  version = "~> 3.0"

  bucket_name              = "sba-ckan-terraform-remote-state"
  lock_table_names         = ["sba-ckan-terraform-state-locktable"]
  bucket_source_account_id = local.account_id
  account_ids = [
    local.account_id
  ]
  log_bucket = "${local.account_id}-${local.region}-logs"
  log_prefix = "s3/${local.account_id}/sba-ckan-terraform-remote-state/"
}
