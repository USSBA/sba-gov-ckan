module "backup-plans" {
  source  = "USSBA/backup-plans/aws"
  version = "~> 6.0"

  enabled = true
  # currently not enabled on this account
  # sns_topic_arn = data.aws_sns_topic.alerts["red"].arn

  cross_region_backup_enabled = true
  cross_region_destination    = "us-west-2"

  daily_backup_enabled   = true
  daily_backup_tag_key   = "BackupDaily"
  daily_backup_tag_value = "true"

  weekly_backup_enabled   = true
  weekly_backup_tag_key   = "BackupWeekly"
  weekly_backup_tag_value = "true"

  quarterly_backup_enabled   = true
  quarterly_backup_tag_key   = "BackupQuarterly"
  quarterly_backup_tag_value = "true"

  opt_in_settings = {
    "Aurora"                 = true
    "CloudFormation"         = false
    "DocumentDB"             = true
    "DynamoDB"               = true
    "EBS"                    = true
    "EC2"                    = true
    "EFS"                    = true
    "FSx"                    = true
    "Neptune"                = true
    "RDS"                    = true
    "Redshift"               = false
    "S3"                     = true
    "SAP HANA on Amazon EC2" = false
    "Storage Gateway"        = true
    "Timestream"             = false
    "VirtualMachine"         = true
  }
}
