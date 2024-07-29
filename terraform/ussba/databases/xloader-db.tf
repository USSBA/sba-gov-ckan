resource "random_password" "xloader_rds_pass" {
  length  = 16
  special = false
  keepers = {
    # Update this to trigger a password change
    trigger_new_pass = "1"
  }
}

resource "aws_ssm_parameter" "xloader_rds_pass" {
  name  = "/xloader/${terraform.workspace}/rds/pass"
  type  = "SecureString"
  value = random_password.xloader_rds_pass.result
}

resource "random_string" "xloader_sg" {
  length  = 4
  lower   = true
  upper   = false
  special = false
  numeric = false
  keepers = {
    unique_id = 1
  }
}

module "xloader_db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 8.3"

  name = "${terraform.workspace}-xloader"

  database_name               = "datastore"
  master_username             = "datastore"
  master_password             = aws_ssm_parameter.xloader_rds_pass.value
  manage_master_user_password = false
  deletion_protection         = true

  engine         = "aurora-postgresql"
  engine_version = "15.4"
  engine_mode    = "provisioned"
  instances      = merge(local.env.db_instances)

  network_type           = "IPV4"
  subnets                = data.aws_subnets.private.ids
  create_db_subnet_group = true
  db_subnet_group_name   = "${terraform.workspace}-xloader"
  vpc_id                 = data.aws_vpc.ckan.id
  monitoring_interval    = 60
  apply_immediately      = true
  storage_encrypted      = true

  skip_final_snapshot       = true
  final_snapshot_identifier = "final-${terraform.workspace}-xloader"

  serverlessv2_scaling_configuration = {
    auto_pause               = terraform.workspace != "prod" ? true : false
    seconds_until_auto_pause = 300
    max_capacity             = 4
    min_capacity             = 1
    timeout_action           = "RollbackCapacityChange"
  }

  # while we get things running we will leave the security group open to the vpc cidr as we trust the traffic within the vpc and there are currently no services.
  security_group_description = "MySQL Security Group for ${terraform.workspace} xloader jobs database"
  security_group_name        = "${terraform.workspace}-mysql-xloader-${random_string.xloader_sg.result}"
  security_group_rules = {
    ex1_ingress = {
      cidr_blocks = [data.aws_vpc.ckan.cidr_block]
    }
  }
  security_group_use_name_prefix = false

  copy_tags_to_snapshot = true

  tags = {
    BackupDaily     = "false"
    BackupQuarterly = "false"
    BackupWeekly    = "false"
  }
}

resource "aws_route53_record" "xloader_db" {
  allow_overwrite = true
  zone_id         = local.env.hosted_zone_id
  name            = "xloader-db.${local.env.domain_name}"
  type            = "CNAME"
  ttl             = 300
  records         = [module.xloader_db.cluster_endpoint]
}
