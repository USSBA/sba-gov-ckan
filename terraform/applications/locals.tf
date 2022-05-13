data "aws_region" "this" {}
data "aws_caller_identity" "this" {}

variable "image_tag" {
  default = "latest"
}

locals {
  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.name
  acls = {
    all       = { rule_action = "allow", protocol = "-1", from_port = 0, to_port = 0, cidr_block = "0.0.0.0/0" }
    http      = { rule_action = "allow", protocol = "6", from_port = 80, to_port = 80, cidr_block = "0.0.0.0/0" }
    https     = { rule_action = "allow", protocol = "6", from_port = 443, to_port = 443, cidr_block = "0.0.0.0/0" }
    ntp       = { rule_action = "allow", protocol = "17", from_port = 123, to_port = 123, cidr_block = "0.0.0.0/0" }
    smtp      = { rule_action = "allow", protocol = "6", from_port = 587, to_port = 587, cidr_block = "0.0.0.0/0" }
    ephemeral = { rule_action = "allow", protocol = "6", from_port = 1024, to_port = 65535, cidr_block = "0.0.0.0/0" }
  }
  # availability zone map used to generate subnets
  zone_map = { a = 0, b = 1 }
  ckan = {
    default = {
      name                 = "ckan-${terraform.workspace}"
      zones                = formatlist("%s%s", local.region, keys(local.zone_map))
      hosted_zone_id       = "Z34GMHAZJS247A"
      image_tag_datapusher = var.image_tag #"v1.2.0"
      image_tag_solr       = var.image_tag #"v1.2.0"
      image_tag_web        = var.image_tag #"v1.2.0"
      rds_username         = "ckan_default"
      rds_database_name    = "ckan_default"
      rds_instance_class   = "db.t3.micro"
    }
    staging = {
      single_nat_gateway          = true
      cidr                        = "10.250.0.0/16"
      domain_name                 = "data.staging.sba.gov"
      desired_capacity_ckan       = 1
      desired_capacity_datapusher = 1
      desired_capacity_solr       = 1 # never exceed 1 for solr
    }
    production = {
      single_nat_gateway          = false
      cidr                        = "10.251.0.0/16"
      domain_name                 = "data.sba.gov"
      desired_capacity_ckan       = 3
      desired_capacity_datapusher = 2
      desired_capacity_solr       = 1 # never exceed 1 for solr
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
}


# data elements
data "aws_ssm_parameter" "google_analytics_id" {
  name = "/ckan/google_analytics_id"
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
  name = "/ckan/${terraform.workspace}/db_password/postgres"
}
data "aws_ssm_parameter" "ses_user" {
  name = "SES_USER"
}
data "aws_ssm_parameter" "ses_password" {
  name = "SES_PASSWORD"
}
data "aws_acm_certificate" "ssl" {
  domain   = local.env.domain_name
  statuses = ["ISSUED"]
}
