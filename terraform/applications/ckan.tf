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
  version = "~> 9.3"

  # cloud watch logging
  log_group_name              = "/ecs/${local.env.name}/web"
  log_group_retention_in_days = 90

  # application load-balancer access logs
  alb_log_bucket_name = "${local.account_id}-${local.region}-logs"
  alb_log_prefix      = "alb/ckan/${terraform.workspace}"

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
      image        = "${local.prefix_ecr}/ckan:${var.image_tag}"
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

