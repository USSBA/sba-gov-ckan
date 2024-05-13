data "aws_region" "this" {}
data "aws_caller_identity" "this" {}

data "aws_s3_bucket" "logs" {
  bucket = "${local.account_id}-${local.region}-logs"
}

variable "image_tag" {
  default = "latest"
}

locals {
  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.name
  ckan = {
    default = {
      name = "ckan-${terraform.workspace}"
      #TODO: Remove once CKAN migration is complete. Leaving behind for easy toggle in case CKAN modifications must be made in sba.gov
      # sba.gov zone: "Z34GMHAZJS247A"
      hosted_zone_id     = "Z1043853321RLHLEHIM4V"
      rds_username       = "ckan_default"
      rds_database_name  = "ckan_default"
      rds_instance_class = "db.t3.micro"
    }
    staging = {
      single_nat_gateway = true
      #TODO: Remove once CKAN migration is complete. Leaving behind for easy toggle in case CKAN modifications must be made in sba.gov
      # sba.gov domain: "data.staging.sba.gov"
      domain_name           = "staging.ckan.ussba.io"
      desired_capacity_ckan = 1
      desired_capacity_solr = 1 # never exceed 1 for solr

      # cloudfront defaults
      default_ttl = 0
      max_ttl     = 0
      min_ttl     = 0
    }
    production = {
      single_nat_gateway    = false
      domain_name           = "production.ckan.ussba.io" #"data.sba.gov"
      desired_capacity_ckan = 1                          #3
      desired_capacity_solr = 1                          # never exceed 1 for solr

      # cloudfront defaults
      default_ttl = 604800
      max_ttl     = 604800
      min_ttl     = 604800
    }
  }

  # environment
  env = merge(local.ckan.default, local.ckan[terraform.workspace])

  # prefix for private ecr images
  prefix_ecr = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"

  # domain names
  fqdn_cloudfront = "cloudfront.${local.env.domain_name}"
  fqdn_datapusher = "datapusher.${local.env.domain_name}"
  fqdn_postgres   = "postgres.${local.env.domain_name}"
  fqdn_redis      = "redis.${local.env.domain_name}"
  fqdn_solr       = "solr.${local.env.domain_name}"
  fqdn_web        = "web.${local.env.domain_name}"
  fqdn_data       = "data.${local.env.domain_name}"
}


# data elements
data "aws_ssm_parameter" "google_analytics_id" {
  name = "/ckan/${terraform.workspace}/google_analytics_id"
}
data "aws_ssm_parameter" "google_analytics_password" {
  name = "/ckan/${terraform.workspace}/google_analytics_password"
}
data "aws_ssm_parameter" "api_token" {
  name = "/ckan/${terraform.workspace}/api_token_secret"
}
data "aws_ssm_parameter" "app_uuid" {
  name = "/ckan/${terraform.workspace}/app_uuid"
}
data "aws_ssm_parameter" "session_secret" {
  name = "/ckan/${terraform.workspace}/session_secret"
}
data "aws_ssm_parameter" "db_password" {
  name = "/ckan/${terraform.workspace}/rds/pass"
}
data "aws_ssm_parameter" "sysadmin_pass" {
  name = "/ckan/${terraform.workspace}/sysadmin/pass"
}
data "aws_ssm_parameter" "datapusher_api_token" {
  name = "/ckan/${terraform.workspace}/datapusher/api_token"
}
data "aws_ssm_parameter" "xloader_db_password" {
  name = "/xloader/staging/rds/pass"
}
data "aws_ssm_parameter" "jwt_secret" {
  name = "/ckan/${terraform.workspace}/jwt_encode_secret"
}
# SMTP will be reconfigured in a future sprint
#data "aws_ssm_parameter" "ses_user" {
#  name = "SES_USER"
#}
#data "aws_ssm_parameter" "ses_password" {
#  name = "SES_PASSWORD"
#}
data "aws_acm_certificate" "ssl" {
  domain   = local.env.domain_name
  statuses = ["ISSUED"]
}
data "aws_rds_cluster" "ckan" {
  cluster_identifier = "${terraform.workspace}-ckan"
}
data "aws_rds_cluster" "xloader" {
  cluster_identifier = "${terraform.workspace}-xloader"
}
