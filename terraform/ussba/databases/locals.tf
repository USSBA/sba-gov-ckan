data "aws_region" "this" {}
data "aws_caller_identity" "this" {}

locals {
  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.name

  ckan = {
    default = {
      name               = "ckan-${terraform.workspace}"
      hosted_zone_id     = "Z1043853321RLHLEHIM4V"
      rds_username       = "ckan_default"
      rds_database_name  = "ckan_default"
      rds_instance_class = "db.t3.micro"
      rds_dns_prefix     = "postgres"
    }
    staging = {
      domain_name = "staging.ckan.ussba.io"
      db_instances = {
        one = {
          instance_class = "db.serverless"
        }
      }
    }
    production = {
      domain_name = "data.sba.gov"
      db_instances = {
        one = {
          instance_class = "db.serverless"
        }
      }
    }
  }

  # environment
  env = merge(local.ckan.default, local.ckan[terraform.workspace])

  # domain names
  fqdn_postgres = "postgres.${local.env.domain_name}"
  fqdn_redis    = "redis.${local.env.domain_name}"
}
