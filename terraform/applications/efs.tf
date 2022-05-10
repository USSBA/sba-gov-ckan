module "efs" {
  for_each                = toset(["web", "solr"])
  source                  = "../modules/efs"
  name                    = "${local.env.name}-${each.key}"
  mount_target_subnet_ids = module.vpc.private_subnets
  vpc_id                  = module.vpc.vpc_id
  allowed_cidr_blocks     = [local.env.cidr]
  efs_tags = {
    BackupWeekly    = "true"
    BackupQuarterly = "true"
  }
}

