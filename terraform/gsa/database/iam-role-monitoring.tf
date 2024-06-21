resource "aws_iam_role" "monitoring" {
  name                = "ckan-${terraform.workspace}-rds-monitoring"
  assume_role_policy  = data.aws_iam_policy_document.monitoring.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
}

data "aws_iam_policy_document" "monitoring" {
  statement {
    sid     = "monitoring"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}
