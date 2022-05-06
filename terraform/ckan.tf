resource "aws_ecs_cluster" "ckan" {
  name = local.env.name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

module "efs" {
  for_each                = toset(["web", "solr"])
  source                  = "./modules/efs"
  name                    = "${local.env.name}-${each.key}"
  mount_target_subnet_ids = module.vpc.private_subnets
  vpc_id                  = module.vpc.vpc_id
  allowed_cidr_blocks     = [local.env.cidr]
  efs_tags = {
    BackupWeekly    = "true"
    BackupQuarterly = "true"
  }
}

module "postgres" {
  source              = "./modules/postgres"
  name                = local.env.name
  instance_class      = local.env.rds_instance_class
  database_name       = local.env.rds_database_name
  database_password   = data.aws_ssm_parameter.db_password.value
  database_username   = local.env.rds_username
  fqdn                = local.fqdn_postgres
  hosted_zone_id      = local.env.hosted_zone_id
  vpc_id              = module.vpc.vpc_id
  allowed_cidr_blocks = [local.env.cidr]
  subnet_ids          = module.vpc.private_subnets
  snapshot_identifier = "ckan-${terraform.workspace}-migration"
  tags = {
    BackupWeekly    = "true"
    BackupQuarterly = "true"
  }
}

module "redis" {
  source              = "./modules/redis"
  name                = local.env.name
  subnet_ids          = module.vpc.private_subnets
  hosted_zone_id      = local.env.hosted_zone_id
  fqdn                = local.fqdn_redis
  vpc_id              = module.vpc.vpc_id
  allowed_cidr_blocks = [local.env.cidr]
}

module "ckan_solr" {
  source  = "USSBA/easy-fargate-service/aws"
  version = "~> 6.3"
  #source     = "../../../terraform-aws-easy-fargate-service"
  depends_on = [module.efs]

  # logging
  log_group_name              = "/ecs/${local.env.name}/solr"
  log_group_retention_in_days = 90

  # task
  family      = "${local.env.name}-solr"
  task_cpu    = 2048
  task_memory = 4096

  # scaling
  desired_capacity                   = local.env.desired_capacity_solr
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  # networking
  service_fqdn           = local.fqdn_solr
  hosted_zone_id         = local.env.hosted_zone_id
  private_subnet_ids     = module.vpc.private_subnets
  vpc_id                 = module.vpc.vpc_id
  listeners              = [{ port = 8983, protocol = "HTTP", action = { type = "forward" } }]
  enable_execute_command = true

  # container(s)
  cluster_name   = aws_ecs_cluster.ckan.name
  container_port = 8983
  container_definitions = [
    {
      name         = "solr"
      portMappings = [{ containerPort = 8983 }]
      image        = "${local.prefix_ecr}/ckan-solr:${local.env.image_tag_solr}"
    }
  ]

  # efs configuration(s)
  efs_configs = [
    {
      container_name = "solr"
      container_path = "/opt/solr/server/solr/ckan/data/"
      file_system_id = module.efs["solr"].id
      root_directory = "/"
    }
  ]
}

module "ckan_datapusher" {
  source  = "USSBA/easy-fargate-service/aws"
  version = "~> 6.3"
  #source = "../../../terraform-aws-easy-fargate-service"

  # logging
  log_group_name              = "/ecs/${local.env.name}/datapusher"
  log_group_retention_in_days = 90

  # task
  family      = "${local.env.name}-datapusher"
  task_cpu    = 2048
  task_memory = 4096

  # scaling
  desired_capacity = local.env.desired_capacity_datapusher

  # networking
  service_fqdn           = local.fqdn_datapusher
  hosted_zone_id         = local.env.hosted_zone_id
  private_subnet_ids     = module.vpc.private_subnets
  vpc_id                 = module.vpc.vpc_id
  listeners              = [{ port = 8800, protocol = "HTTP", action = { type = "forward" } }]
  enable_execute_command = true

  # container(s)
  cluster_name   = aws_ecs_cluster.ckan.name
  container_port = 8800
  container_definitions = [
    {
      name         = "datapusher"
      portMappings = [{ containerPort = 8800 }]
      image        = "${local.prefix_ecr}/ckan-datapusher:${local.env.image_tag_datapusher}"
    }
  ]
}

locals {
  secrets = {
    default = [
      { name = "SESSION_SECRET", valueFrom = data.aws_ssm_parameter.session_secret.arn },
      { name = "APP_UUID", valueFrom = data.aws_ssm_parameter.app_uuid.arn },
      { name = "CKAN_API_TOKEN_SECRET", valueFrom = data.aws_ssm_parameter.api_token.arn },
      { name = "POSTGRES_PASSWORD", valueFrom = data.aws_ssm_parameter.db_password.arn },
      { name = "CKAN_SMTP_USER", valueFrom = data.aws_ssm_parameter.ses_user.arn },
      { name = "CKAN_SMTP_PASSWORD", valueFrom = data.aws_ssm_parameter.ses_password.arn },
    ]
    staging    = []
    production = [{ name = "CKAN_GOOGLE_ANALYTICS_ID", valueFrom = data.aws_ssm_parameter.google_analytics_id.arn }]
  }
  ckan_secrets = toset(concat(local.secrets.default, local.secrets[terraform.workspace]))
}

module "ckan_web" {
  source  = "USSBA/easy-fargate-service/aws"
  version = "~> 6.3"
  #source = "../../../terraform-aws-easy-fargate-service"

  # logging
  log_group_name              = "/ecs/${local.env.name}/web"
  log_group_retention_in_days = 90

  # task
  family      = "${local.env.name}-web"
  task_cpu    = 2048
  task_memory = 4096

  # scaling
  desired_capacity = local.env.desired_capacity_ckan

  # networking
  service_fqdn           = local.fqdn_web
  hosted_zone_id         = local.env.hosted_zone_id
  certificate_arn        = data.aws_acm_certificate.ssl.arn
  private_subnet_ids     = module.vpc.private_subnets
  public_subnet_ids      = module.vpc.public_subnets
  vpc_id                 = module.vpc.vpc_id
  enable_execute_command = true

  # Health Checks
  health_check_timeout             = 20 # Can get slow when large file transfers are happening
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 10
  health_check_path                = "/?alb_healthcheck_ckan_web"

  # container(s)
  cluster_name   = aws_ecs_cluster.ckan.name
  container_port = 80
  container_definitions = [
    {
      name         = "web"
      portMappings = [{ containerPort = 80 }]
      image        = "${local.prefix_ecr}/ckan:${local.env.image_tag_web}"
      environment = [
        { name = "CKAN_PORT", value = "80" },
        { name = "CKAN_SITE_URL", value = "https://${local.env.domain_name}" },
        { name = "CKAN_DATAPUSHER_CALLBACK_URL", value = "https://${local.fqdn_web}" },
        { name = "POSTGRES_FQDN", value = local.fqdn_postgres },
        { name = "REDIS_FQDN", value = local.fqdn_redis },
        { name = "SOLR_PORT", value = "8983" },
        { name = "SOLR_FQDN", value = local.fqdn_solr },
        { name = "DATAPUSHER_PORT", value = "8800" },
        { name = "DATAPUSHER_FQDN", value = local.fqdn_datapusher },
        { name = "CKAN_SMTP_MAIL_FROM", value = "websupport@sba.gov" },

      ]
      secrets = local.ckan_secrets
    }
  ]

  # efs configuration(s)
  efs_configs = [
    {
      container_name = "web"
      container_path = "/var/lib/ckan"
      file_system_id = module.efs["web"].id
      root_directory = "/"
    }
  ]
}

resource "aws_route53_record" "cloudfront" {
  zone_id = local.env.hosted_zone_id
  name    = local.fqdn_cloudfront
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "domain" {
  zone_id = local.env.hosted_zone_id
  name    = local.env.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
