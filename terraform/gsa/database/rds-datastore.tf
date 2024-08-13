resource "random_password" "datastore_pass" {
  length  = 16
  special = false
  keepers = {
    trigger_new_pass = "1"
  }
}

resource "aws_ssm_parameter" "datastore_user" {
  name  = "/ckan/${terraform.workspace}/datastore/user"
  type  = "SecureString"
  value = "datastore"
}

resource "aws_ssm_parameter" "datastore_pass" {
  name  = "/ckan/${terraform.workspace}/datastore/pass"
  type  = "SecureString"
  value = random_password.datastore_pass.result
}

resource "aws_rds_cluster" "datastore" {
  cluster_identifier              = "${terraform.workspace}-datastore"
  engine                          = "aurora-postgresql"
  db_subnet_group_name            = aws_db_subnet_group.ckan.name
  database_name                   = aws_ssm_parameter.datastore_user.value
  master_username                 = aws_ssm_parameter.datastore_user.value
  master_password                 = aws_ssm_parameter.datastore_pass.value
  enabled_cloudwatch_logs_exports = ["postgresql"]
  skip_final_snapshot             = true #terraform.workspace != "production"
  copy_tags_to_snapshot           = true
  deletion_protection             = false
  storage_encrypted               = true

  # Notes:
  # - In order to enable the data api (enable_http_endpoint) the minimal requires engine version must be 16.1.
  # - It also appears that once the cluster is deployed you must manually enabled/disable the data api, it does not appear to work via terraform.
  #   https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/data-api.html
  #   https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.Aurora_Fea_Regions_DB-eng.Feature.Data_API.html#Concepts.Aurora_Fea_Regions_DB-eng.Feature.Data_API.apg
  enable_http_endpoint        = true
  engine_version              = "16.2"
  allow_major_version_upgrade = true
  apply_immediately           = true

  vpc_security_group_ids = [
    aws_security_group.ckan.id
  ]

  serverlessv2_scaling_configuration {
    max_capacity = 8
    min_capacity = 6
  }

  tags = {
    BackupDaily     = terraform.workspace == "production"
    BackupQuarterly = terraform.workspace == "production"
    BackupWeekly    = terraform.workspace == "production"
  }
}

resource "aws_rds_cluster_instance" "datastore_instances" {
  count               = 1
  promotion_tier      = 1
  identifier          = "${aws_rds_cluster.datastore.cluster_identifier}-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.datastore.cluster_identifier
  instance_class      = "db.serverless"
  engine              = aws_rds_cluster.datastore.engine
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.monitoring.arn
}
