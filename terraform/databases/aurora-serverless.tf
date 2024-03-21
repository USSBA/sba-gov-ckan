resource "random_password" "ckan_rds_pass" {
  length  = 16
  special = false
  keepers = {
    # Update this to trigger a password change
    trigger_new_pass = "1"
  }
}

resource "aws_ssm_parameter" "ckan_rds_pass" {
  name  = "/ckan/${terraform.workspace}/rds/pass"
  type  = "SecureString"
  value = random_password.ckan_rds_pass.result
}


module "ckan_db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 8.3"

  name = "${terraform.workspace}-ckan"

  master_username             = "ckan_default"
  master_password             = random_password.ckan_rds_pass.result
  manage_master_user_password = false
  deletion_protection         = true

  engine               = "aurora-postgresql"
  engine_version       = "11.21"
  engine_mode          = "serverless"
  enable_http_endpoint = true
  network_type         = "IPV4"

  subnets                = data.aws_subnets.private.ids
  create_db_subnet_group = true
  vpc_id                 = data.aws_vpc.ckan.id
  monitoring_interval    = 60
  apply_immediately      = true #local.env.apply_db_changes_immediately
  storage_encrypted      = true
  #db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.ckan_rds.id

  skip_final_snapshot       = true #local.env.db_skip_final_snapshot
  final_snapshot_identifier = "final-${terraform.workspace}-ckan"

  database_name = "ckan_default"

  scaling_configuration = {
    auto_pause               = false # in dev we should probably set this to true
    seconds_until_auto_pause = 300   # with a auto_pause of about 30-60 minutes or so
    max_capacity             = 64
    min_capacity             = contains(["prod"], terraform.workspace) ? 32 : 4
    timeout_action           = "RollbackCapacityChange"
  }

  copy_tags_to_snapshot = true

  tags = {
    BackupDaily     = terraform.workspace == "prod" ? true : false
    BackupQuarterly = terraform.workspace == "prod" ? true : false
    BackupWeekly    = terraform.workspace == "prod" ? true : false
  }
}

resource "aws_route53_record" "ckan_db" {
  allow_overwrite = true
  zone_id         = local.env.hosted_zone_id
  name            = "${local.env.rds_dns_prefix}.${local.env.domain_name}"
  type            = "CNAME"
  ttl             = 300
  records         = [module.ckan_db.cluster_endpoint]
}
