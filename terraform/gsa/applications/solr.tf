module "ckan_solr" {
  source  = "USSBA/easy-fargate-service/aws"
  version = "~> 11.1"

  depends_on = [module.efs]

  # cloud watch logging
  log_group_name              = "/ecs/${local.env.name}/solr"
  log_group_retention_in_days = 90

  # application load-balancer access logs
  alb_log_bucket_name = "${local.account_id}-${local.region}-logs"
  alb_log_prefix      = "alb/ckan-solr/${terraform.workspace}"
  task_policy_json    = data.aws_iam_policy_document.task.json

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
  private_subnet_ids     = data.aws_subnets.private.ids
  vpc_id                 = data.aws_vpc.ckan.id
  listeners              = [{ port = 8983, protocol = "HTTP", action = { type = "forward" } }]
  enable_execute_command = true

  # container(s)
  cluster_name   = "ckan-${terraform.workspace}"
  container_port = 8983
  container_definitions = [
    {
      name         = "solr"
      #command      = ["sh", "-c", "/app/solr/local_setup.sh"]
      portMappings = [{ containerPort = 8983 }]
      # Pulling the supported image straight from CKAN. Should help reduce complexity and management required by IAS.
      image = "898673322888.dkr.ecr.us-east-1.amazonaws.com/gsa-ckan-solr:latest"
    }
  ]

  # efs configuration(s)
  efs_configs = [
    {
      container_name = "solr"
      #container_path = "/opt/solr/server/solr/ckan/data/"
      container_path = "/opt/solr-8.11.1/server/solr/data/"
      file_system_id = module.efs["solr"].id
      root_directory = "/"
    },
    #{
    #  container_name = "solr"
    #  container_path = "/var/solr/logs/"
    #  file_system_id = module.efs["solr"].id
    #  root_directory = "/logs"
    #}
  ]
}

