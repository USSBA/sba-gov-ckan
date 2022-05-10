module "ckan_datapusher" {
  source  = "USSBA/easy-fargate-service/aws"
  version = "~> 7.0"
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
