
locals {
  secrets = {
    default = [
      # do we need these?
      #{ name = "SESSION_SECRET", valueFrom = data.aws_ssm_parameter.session_secret.arn },
      #{ name = "APP_UUID", valueFrom = data.aws_ssm_parameter.app_uuid.arn },
      { name = "POSTGRES_PASSWORD", valueFrom = data.aws_ssm_parameter.db_password.arn },
      { name = "CKAN_SYSADMIN_PASSWORD", valueFrom = data.aws_ssm_parameter.sysadmin_pass.arn },
      { name = "CKAN___GOOGLEANALYTICS__ID", valueFrom = data.aws_ssm_parameter.google_analytics_id.arn },
      { name = "CKAN___GOOGLEANALYTICS__PASSWORD", valueFrom = data.aws_ssm_parameter.google_analytics_password.arn },
      #      { name = "CKAN_SMTP_USER", valueFrom = data.aws_ssm_parameter.ses_user.arn },
      #      { name = "CKAN_SMTP_PASSWORD", valueFrom = data.aws_ssm_parameter.ses_password.arn },
    ]
    staging    = []
    production = [{ name = "CKAN_GOOGLE_ANALYTICS_ID", valueFrom = data.aws_ssm_parameter.google_analytics_id.arn }]
  }
  ckan_secrets = toset(concat(local.secrets.default, local.secrets[terraform.workspace]))
}

module "ckan_web" {
  source  = "USSBA/easy-fargate-service/aws"
  version = "~> 11.1"

  # cloud watch logging
  log_group_name              = "/ecs/${local.env.name}/web"
  log_group_retention_in_days = 90

  # application load-balancer access logs
  alb_log_bucket_name = "${local.account_id}-${local.region}-logs"
  alb_log_prefix      = "alb/ckan/${terraform.workspace}"
  task_policy_json    = data.aws_iam_policy_document.task.json

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
  private_subnet_ids     = data.aws_subnets.private.ids
  public_subnet_ids      = data.aws_subnets.public.ids
  vpc_id                 = data.aws_vpc.ckan.id
  enable_execute_command = true

  # Health Checks
  health_check_timeout             = 20 # Can get slow when large file transfers are happening
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 10
  health_check_path                = "/?alb_healthcheck_ckan_web"

  # container(s)
  cluster_name   = aws_ecs_cluster.ckan.name
  container_port = 5000
  container_definitions = [
    {
      name         = "web"
      portMappings = [{ containerPort = 5000 }]
      image        = "${local.prefix_ecr}/ckan:${var.image_tag}"
      environment = [
        # CKAN Defaults
        { name = "CKAN_VERSION", value = "2.10.0" },
        { name = "CKAN_SITE_ID", value = "default" },
        { name = "CKAN_STORAGE_PATH", value = "/var/lib/ckan" },
        { name = "CKAN___BEAKER__SESSION__SECRET", value = "${data.aws_ssm_parameter.session_secret.value}" },
        { name = "CKAN___API_TOKEN__JWT__ENCODE__SECRET", value = "string:${data.aws_ssm_parameter.jwt_secret.value}" },
        { name = "CKAN___API_TOKEN__JWT__DECODE__SECRET", value = "string:${data.aws_ssm_parameter.jwt_secret.value}" },
        { name = "CKAN__AUTH__CREATE_USER_VIA_API", value = "false" },
        { name = "CKAN__AUTH__CREATE_USER_VIA_WEB", value = "false" },
        # usmetadata plugins appears to cause plugins after it to not load properly.
        # datajson_validator appears to cause errors after ckan loads and is causing errors with other plugins.
        #{ name = "CKAN__PLUGINS", value = "datastore datapusher stats text_view recline_view dcat_usmetadata usmetadata googleanalytics datajson harvest datajson_validator datajson_harvest envvars" },
        { name = "CKAN__PLUGINS", value = "image_view text_view recline_view datastore googleanalytics xloader envvars" },
        # Google Analytics
        { name = "CKAN___GOOGLEANALYTICS__ACCOUNT", value = "fake" },
        { name = "CKAN___GOOGLEANALYTICS__USERNAME", value = "fake" },
        # Domains & FQDN'S
        { name = "CKAN_SITE_URL", value = "https://data.${local.env.domain_name}" },
        { name = "CKAN_SOLR_URL", value = "http://${local.fqdn_solr}:8983/solr/ckan" },
        { name = "CKAN__DATAPUSHER__URL", value = "http://${local.fqdn_web}" },
        { name = "CKAN_REDIS_URL", value = "redis://${local.fqdn_redis}:6379/1" },
        { name = "REDIS_FQDN", value = local.fqdn_redis },
        { name = "SOLR_FQDN", value = local.fqdn_solr },
        # SQLAlchemy URLs
        { name = "CKAN_SQLALCHEMY_URL", value = "postgresql://ckan_default:${data.aws_ssm_parameter.db_password.value}@${data.aws_rds_cluster.ckan.cluster_identifier}/ckan_default" },
        { name = "CKAN_DATASTORE_WRITE_URL", value = "postgresql://datastore:${data.aws_ssm_parameter.xloader_db_password.value}@${data.aws_rds_cluster.xloader.cluster_identifier}/datastore" },
        { name = "CKAN_DATASTORE_READ_URL", value = "postgresql://datastore_ro:datastore@${data.aws_rds_cluster.xloader.cluster_identifier}/datastore" },
        { name = "TEST_CKAN_SQLALCHEMY_URL", value = "postgresql://ckan_default:${data.aws_ssm_parameter.db_password.value}@${data.aws_rds_cluster.ckan.cluster_identifier}/ckan_test" },
        { name = "TEST_CKAN_DATASTORE_WRITE_URL", value = "postgresql://datastore:${data.aws_ssm_parameter.xloader_db_password.value}@${data.aws_rds_cluster.xloader.cluster_identifier}/datastore_test" },
        { name = "TEST_CKAN_DATASTORE_READ_URL", value = "postgresql://datastore_ro:datastore@${data.aws_rds_cluster.xloader.cluster_identifier}/datastore_test" },
        # Ports
        { name = "CKAN_PORT", value = "5000" },
        { name = "DATAPUSHER_PORT", value = "8800" },
        { name = "SOLR_PORT", value = "8983" },
        # Database credentials & Configuration
        { name = "DATASTORE_READONLY_USER", value = "datastore_ro" },
        { name = "DATASTORE_READONLY_PASSWORD", value = "datastore" },
        { name = "DATASTORE_DB", value = "datastore" },
        { name = "POSTGRES_HOST", value = local.fqdn_postgres },
        { name = "POSTGRES_USER", value = "ckan_default" },
        { name = "POSTGRES_DB", value = "ckan_default" },
        { name = "POSTGRES_FQDN", value = local.fqdn_postgres },
        # SMTP Configuration
        # SMTP will be reconfigured in a future sprint
        { name = "CKAN_SYSADMIN_NAME", value = "ckan_admin" },
        { name = "CKAN_SYSADMIN_EMAIL", value = "your_email@example.com" },
        { name = "CKAN_SMTP_SERVER", value = "smtp.corporateict.domain:25" },
        { name = "CKAN_SMTP_STARTTLS", value = "True" },
        { name = "CKAN_SMTP_MAIL_FROM", value = "websupport@sba.gov" },
        # XLoader
        { name = "CKANEXT__XLOADER__JOBS_DB__URI", value = "postgresql://datastore:${data.aws_ssm_parameter.xloader_db_password.value}@${data.aws_rds_cluster.xloader.cluster_identifier}/datastore" },
        { name = "CKANEXT__XLOADER__FORMATS", value = "csv application/csv xls xlsx application/vnd.ms-excel" },
        { name = "CKANEXT__XLOADER__MAX_CONTENT_LENGTH", value = "1000000000" },
        { name = "CKANEXT__XLOADER__JUST_LOAD_WITH_MESSYTABLES", value = "False" },
        { name = "CKANEXT__XLOADER__JOB_TIMEOUT", value = "3600" },
        { name = "CKANEXT__XLOADER__MAX_EXCERPT_LINES", value = "100" },
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

data "aws_rds_cluster" "aurora" {
  cluster_identifier = "${terraform.workspace}-ckan"
}

resource "aws_security_group_rule" "ckan2aurora" {
  for_each                 = data.aws_rds_cluster.aurora.vpc_security_group_ids
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.ckan_web.security_group_id
  security_group_id        = each.value
}
