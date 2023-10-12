locals {

  region = "us-east-1"

  zone_map = {
    a = 0,
    b = 1
  }

  acls = {
    all       = { rule_action = "allow", protocol = "-1", from_port = 0, to_port = 0, cidr_block = "0.0.0.0/0" }
    http      = { rule_action = "allow", protocol = "6", from_port = 80, to_port = 80, cidr_block = "0.0.0.0/0" }
    https     = { rule_action = "allow", protocol = "6", from_port = 443, to_port = 443, cidr_block = "0.0.0.0/0" }
    ntp       = { rule_action = "allow", protocol = "17", from_port = 123, to_port = 123, cidr_block = "0.0.0.0/0" }
    smtp      = { rule_action = "allow", protocol = "6", from_port = 587, to_port = 587, cidr_block = "0.0.0.0/0" }
    ephemeral = { rule_action = "allow", protocol = "6", from_port = 1024, to_port = 65535, cidr_block = "0.0.0.0/0" }
  }

  ckan = {
    default = {
      name  = "ckan-${terraform.workspace}"
      zones = formatlist("%s%s", local.region, keys(local.zone_map))
      #TODO: Remove once CKAN migration is complete. Leaving behind for easy toggle in case CKAN modifications must be made in sba.gov
      # sba.gov zone: "Z34GMHAZJS247A"
      hosted_zone_id     = "Z1043853321RLHLEHIM4V"
      rds_username       = "ckan_default"
      rds_database_name  = "ckan_default"
      rds_instance_class = "db.t3.micro"
    }
    staging = {
      single_nat_gateway = true
      cidr               = "10.250.0.0/16"
      #TODO: Remove once CKAN migration is complete. Leaving behind for easy toggle in case CKAN modifications must be made in sba.gov
      # sba.gov domain: "data.staging.sba.gov"
      domain_name                 = "staging.ckan.ussba.io"
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

  env = merge(local.ckan.default, local.ckan[terraform.workspace])
}
