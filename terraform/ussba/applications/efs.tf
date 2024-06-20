module "efs" {
  for_each                = toset(["web", "solr"])
  source                  = "../modules/efs"
  name                    = "${local.env.name}-${each.key}"
  mount_target_subnet_ids = data.aws_subnets.private.ids
  vpc_id                  = data.aws_vpc.ckan.id
  allowed_cidr_blocks     = [data.aws_vpc.ckan.cidr_block]
  efs_tags = {
    BackupWeekly    = "true"
    BackupQuarterly = "true"
  }
}

