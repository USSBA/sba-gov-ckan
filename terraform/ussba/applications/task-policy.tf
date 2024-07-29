data "aws_iam_policy_document" "task" {
  statement {
    actions = [
      "s3:List*",
      "s3:GetBucketLocation",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${data.aws_s3_bucket.logs.arn}/*",
    ]
  }
}
