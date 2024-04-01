module "ckan_datapusher" {
  source  = "USSBA/easy-fargate-service/aws"
  version = "~> 11.1"

  # cloud watch logging
  log_group_name              = "/ecs/${local.env.name}/datapusher"
  log_group_retention_in_days = 90

  # application load-balancer access logs
  alb_log_bucket_name = "${local.account_id}-${local.region}-logs"
  alb_log_prefix      = "alb/ckan-datapusher/${terraform.workspace}"
  task_policy_json    = data.aws_iam_policy_document.task.json

  # task
  family      = "${local.env.name}-datapusher"
  task_cpu    = 2048
  task_memory = 4096

  # scaling
  desired_capacity = local.env.desired_capacity_datapusher

  # networking
  service_fqdn           = local.fqdn_datapusher
  hosted_zone_id         = local.env.hosted_zone_id
  private_subnet_ids     = data.aws_subnets.private.ids
  vpc_id                 = data.aws_vpc.ckan.id
  listeners              = [{ port = 8800, protocol = "HTTP", action = { type = "forward" } }]
  enable_execute_command = true

  # container(s)
  cluster_name   = aws_ecs_cluster.ckan.name
  container_port = 8800
  container_definitions = [
    {
      name         = "datapusher"
      portMappings = [{ containerPort = 8800 }]
      image        = "openknowledge/datapusher"
    }
  ]
}

