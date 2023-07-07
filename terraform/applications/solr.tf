module "ckan_solr" {
  source  = "USSBA/easy-fargate-service/aws"
  version = "~> 9.3"

  depends_on = [module.efs]

  # cloud watch logging
  log_group_name              = "/ecs/${local.env.name}/solr"
  log_group_retention_in_days = 90

  # application load-balancer access logs
  alb_log_bucket_name = "${local.account_id}-${local.region}-logs"
  alb_log_prefix      = "alb/ckan-solr/${terraform.workspace}"

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

