resource "aws_ecs_task_definition" "task" {
  family                   = "${terraform.workspace}-log-cleaner"
  execution_role_arn       = aws_iam_role.exec.arn
  task_role_arn            = aws_iam_role.task.arn
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    cpu_architecture = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "main"
      image     = "public.ecr.aws/ussba/log-cleaner:latest"
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.logs.name
          awslogs-region        = local.region
          awslogs-stream-prefix = "main"
        }
      }
      environment = [
        { name = "RETENTION_IN_DAYS", value = "90" },
      ]
    },
  ])
}
