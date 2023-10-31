data "aws_region" "this" {}
data "aws_caller_identity" "this" {}

locals {
  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.name

  ckan = {
    default = {
      name               = "ckan-${terraform.workspace}"
      hosted_zone_id     = "Z1043853321RLHLEHIM4V" #"Z34GMHAZJS247A"
      rds_username       = "ckan_default"
      rds_database_name  = "ckan_default"
      rds_instance_class = "db.t3.micro"
    }
    staging = {
      domain_name = "staging.ckan.ussba.io" #"data.staging.sba.gov"
    }
    production = {
      domain_name = "data.sba.gov"
    }
  }

  # environment
  env = merge(local.ckan.default, local.ckan[terraform.workspace])

  # domain names
  fqdn_postgres = "postgres.${local.env.domain_name}"
  fqdn_redis    = "redis.${local.env.domain_name}"
}

# data elements
#data "aws_ssm_parameter" "db_password" {
#  name = "/ckan/${terraform.workspace}/db_password/postgres"
#}
