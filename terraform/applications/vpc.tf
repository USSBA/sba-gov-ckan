module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  # general settings
  azs                  = local.env.zones
  cidr                 = local.env.cidr
  name                 = local.env.name
  enable_dns_hostnames = true
  enable_dns_support   = true

  # network address translation settings
  enable_nat_gateway      = true
  single_nat_gateway      = local.env.single_nat_gateway
  map_public_ip_on_launch = true

  # disable default vpc management
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false
  manage_default_vpc            = false

  # public subnets & acl rules
  public_dedicated_network_acl = true
  public_subnets               = [for n in toset(values(local.zone_map)) : cidrsubnet(local.env.cidr, 8, tonumber(n))]
  public_inbound_acl_rules = [
    merge(local.acls.http, { rule_number = 100 }),
    merge(local.acls.https, { rule_number = 101 }),
    merge(local.acls.ntp, { rule_number = 102 }),
    merge(local.acls.smtp, { rule_number = 103 }),
    merge(local.acls.ephemeral, { rule_number = 104 }),
    merge(local.acls.ephemeral, { rule_number = 105, protocol = "udp" })
  ]
  public_outbound_acl_rules = [
    merge(local.acls.all, { rule_number = 100, cidr_block = local.env.cidr }),
    merge(local.acls.http, { rule_number = 101 }),
    merge(local.acls.https, { rule_number = 102 }),
    merge(local.acls.ntp, { rule_number = 103 }),
    merge(local.acls.smtp, { rule_number = 104 }),
    merge(local.acls.ephemeral, { rule_number = 105 }),
  ]

  # private subnets & acl rules
  private_dedicated_network_acl = true
  private_subnets               = [for n in toset(values(local.zone_map)) : cidrsubnet(local.env.cidr, 8, tonumber(n) + 128)]
  private_inbound_acl_rules = [
    merge(local.acls.http, { rule_number = 100, cidr_block = local.env.cidr }),
    merge(local.acls.https, { rule_number = 101, cidr_block = local.env.cidr }),
    merge(local.acls.ntp, { rule_number = 102 }),
    merge(local.acls.ephemeral, { rule_number = 103 }),
  ]
  private_outbound_acl_rules = [
    merge(local.acls.all, { rule_number = 100, cidr_block = local.env.cidr }),
    merge(local.acls.http, { rule_number = 101 }),
    merge(local.acls.https, { rule_number = 102 }),
    merge(local.acls.smtp, { rule_number = 103 }),
    merge(local.acls.ephemeral, { rule_number = 104 }),
  ]
}
