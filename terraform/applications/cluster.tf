resource "aws_ecs_cluster" "ckan" {
  name = local.env.name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
