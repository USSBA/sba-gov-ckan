resource "aws_cloudwatch_log_group" "logs" {
  name              = "/${terraform.workspace}/log-cleaner"
  retention_in_days = 90
}
