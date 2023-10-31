#module "postgres" {
#  source              = "../modules/postgres"
#  name                = local.env.name
#  instance_class      = local.env.rds_instance_class
#  database_name       = local.env.rds_database_name
#  database_password   = data.aws_ssm_parameter.db_password.value
#  database_username   = local.env.rds_username
#  fqdn                = local.fqdn_postgres
#  hosted_zone_id      = local.env.hosted_zone_id
#  vpc_id              = data.aws_vpc.ckan.id
#  allowed_cidr_blocks = [data.aws_vpc.ckan.cidr_block]
#  subnet_ids          = data.aws_subnets.private.ids
#  snapshot_identifier = "ckan-${terraform.workspace}-migration"
#  tags = {
#    BackupWeekly    = "true"
#    BackupQuarterly = "true"
#  }
#}
