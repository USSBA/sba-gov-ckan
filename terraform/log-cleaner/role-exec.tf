resource "aws_iam_role" "exec" {
  name               = "${terraform.workspace}-log-cleaner-exec"
  assume_role_policy = data.aws_iam_policy_document.principal.json
  inline_policy {
    name   = "inline1"
    policy = data.aws_iam_policy_document.exec.json
  }
}

data "aws_iam_policy_document" "exec" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}
