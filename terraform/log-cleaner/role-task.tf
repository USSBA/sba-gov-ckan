resource "aws_iam_role" "task" {
  name               = "${terraform.workspace}-log-cleaner-task"
  assume_role_policy = data.aws_iam_policy_document.principal.json
  inline_policy {
    name   = "inline1"
    policy = data.aws_iam_policy_document.task.json
  }
}

data "aws_iam_policy_document" "task" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DeleteLogStream",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
  }
}
