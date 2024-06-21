resource "aws_ecs_cluster" "cluster" {
  name = "ckan-${terraform.workspace}"
  configuration {
    execute_command_configuration {
      # The logging property determines the behavior of the logging capability of ECS Exec:
      # NONE: logging is turned off
      # DEFAULT: logs are sent to the configured awslogs driver (If the driver isn't configured, then no log is saved.)
      # OVERRIDE: logs are sent to the provided Amazon CloudWatch Logs LogGroup, Amazon S3 bucket, or both
      logging = "OVERRIDE"
      log_configuration {
        s3_bucket_name = "${local.account_id}-${local.region}-logs"
        s3_key_prefix  = "/ecs-exec/${local.account_id}/${terraform.workspace}/"
      }
    }
  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
