module "redis" {
  source              = "../modules/redis"
  name                = local.env.name
  subnet_ids          = data.aws_subnet_ids.private.ids
  hosted_zone_id      = local.env.hosted_zone_id
  fqdn                = local.fqdn_redis
  vpc_id              = data.aws_vpc.ckan.id
  allowed_cidr_blocks = [data.aws_vpc.ckan.cidr_block]
}
