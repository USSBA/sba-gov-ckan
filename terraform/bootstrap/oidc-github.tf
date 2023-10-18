# this data block will find the thumbprint so you do not need to manually run the curl command below.
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# thumbprint
# curl https://token.actions.githubusercontent.com/.well-known/openid-configuration
# openssl s_client -servername token.actions.githubusercontent.com -showcerts -connect token.actions.githubusercontent.com:443
# openssl x509 -in certificate.crt -fingerprint -noout | cut -d'=' -f2 | sed -e 's/://g' | tr '[:upper:]' '[:lower:]'

resource "aws_iam_openid_connect_provider" "oidc_github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [for x in data.tls_certificate.github.certificates : x.sha1_fingerprint]
}

data "aws_iam_policy_document" "principal_github" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc_github.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = formatlist("repo:%s/%s:*", local.github.org, local.github.repos)
    }
  }
}

resource "aws_iam_role" "oidc_github" {
  name_prefix         = "oidc-github"
  description         = "OpenID Connect Role for ${local.github.org} GitHub Action"
  assume_role_policy  = data.aws_iam_policy_document.principal_github.json
  managed_policy_arns = [aws_iam_policy.oidc.arn]
}

resource "aws_iam_policy" "oidc" {
  name   = "github-oidc"
  policy = data.aws_iam_policy_document.oidc.json
}

data "aws_iam_policy_document" "oidc" {
  statement {
    actions = [
      "*"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Deny"
    actions = [
      "dynamodb:DeleteBackup",
      "dynamodb:DeleteTable",
      "dynamodb:DeleteTableReplica",
    ]
    resources = [
      "*"
    ]
  }
  # In the past SBIR had trouble as some of their infra code required deletion of certain s3 objects.
  # for now we are just ensuring the terraform state s3 bucket cannot be deleted by CircleCI.
  statement {
    effect = "Deny"
    actions = [
      "s3:Delete*",
    ]
    resources = [
      "arn:aws:s3:::sba-sbir-terraform"
    ]
  }
  statement {
    effect = "Deny"
    actions = [
      "ec2:DeleteSnapshot",
      "ec2:DeregisterImage",
      "ec2:RunInstances",
      "ec2:PurchaseScheduledInstances",
      "ec2:PurchaseReservedInstancesOffering",
      "ec2:ReleaseAddress",
      "ec2:DeleteKeyPair",
      "ec2:DeleteVolume",
      "ec2:DeleteVpn*",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Deny"
    actions = [
      "rds:DeleteDB*",
      "rds:CreateDB*",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Deny"
    actions = [
      "backup:DeleteBackupSelection",
      "backup:DeleteBackupVault",
      "backup:DeleteRecoveryPoint",
      "backup:Start*",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Deny"
    actions = [
      "logs:DeleteLogGroup",
      "logs:DeleteLogStream",
      "cloudwatch:DeleteDashboards",
      "cloudwatch:PutDashboard",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DeleteMetricStreams",
      "cloudwatch:StopMetricStreams",
      "cloudwatch:SetAlarmState",
      "cloudwatch:PutMetricData",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Deny"
    actions = [
      "elasticfilesystem:DeleteFileSystem",
      "elasticfilesystem:DeleteMountTarget",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    # Miscellaneous compute resources CircleCI should not have any rights to.
    effect = "Deny"
    actions = [
      "eks:*",
      "sagemaker:*",
      "emr:*",
      "braket:*",
      "robomaker:*",
      "groundstation:*",
      "managedblockchain:*",
      "sumerian:*",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Deny"
    actions = [
      "cognito-idp:AdminDisableUser",
      "cognito-idp:AdminResetUserPassword",
      "cognito-idp:ChangePassword",
      "cognito-idp:Delete*",
      "cognito-idp:DisassociateWebACL",
      "cognito-idp:SignUp"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Deny"
    actions = [
      "secretsmanager:DeleteSecret",
      "ssm:DeleteParameter",
      "ssm:DeleteParameters",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    # CircleCI should not have any rights to create users or access keys.
    effect = "Deny"
    actions = [
      "iam:CreateAccessKey",
      "iam:CreateUser",
      "iam:DeleteUser",
      "iam:UpdateAccessKey",
      "iam:ListAccessKeys",
      "iam:DeleteAccountAlias",
      "iam:DeleteAccountPasswordPolicy",
      "iam:DeleteOpenIDConnectProvider",
    ]
    resources = [
      "*"
    ]
  }
}
