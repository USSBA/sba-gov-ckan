# variables
variable "name" {
  type = string
}
variable "instance_class" {
  type = string
}
variable "database_name" {
  type = string
}
variable "database_password" {
  type      = string
  sensitive = true
}
variable "database_username" {
  type = string
}
variable "fqdn" {
  type = string
}
variable "hosted_zone_id" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "allowed_cidr_blocks" {
  type = list(string)
}
variable "subnet_ids" {
  type = list(string)
}
variable "tags" {
  type    = map(any)
  default = {}
}
variable "snapshot_identifier" {
  type = string
}

# postgres
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 4.0"

  # storage
  allocated_storage = 60
  storage_encrypted = true
  storage_type      = "gp2"

  # maintenance and backup
  backup_retention_period          = 35
  backup_window                    = "03:30-04:30"
  copy_tags_to_snapshot            = true
  final_snapshot_identifier_prefix = "${var.name}-final"
  identifier                       = var.name
  maintenance_window               = "sun:00:00-sun:03:00"
  skip_final_snapshot              = true

  # instance
  deletion_protection = false
  # create_db_subnet_group is now set to false by default in the new module version
  # which tries to destroy the current subnet group.
  create_db_subnet_group = true
  engine                 = "postgres"
  engine_version         = "11.13"
  family                 = "postgres11"
  instance_class         = var.instance_class
  major_engine_version   = 11
  multi_az               = true
  db_name                = var.database_name
  port                   = 5432
  snapshot_identifier    = var.snapshot_identifier

  # credentials
  password = var.database_password
  username = var.database_username
  # update module has create_random_password set to true, which we do not want.
  create_random_password = false

  # networking
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]

  # tags
  tags = var.tags
  # new module version has added a new db_instance_tag attribute
  db_instance_tags = { "Name" = var.name }
}

# dns
resource "aws_route53_record" "postgres" {
  zone_id = var.hosted_zone_id
  name    = var.fqdn
  type    = "CNAME"
  ttl     = "300"
  records = [module.rds.db_instance_address]
}

# security group
resource "aws_security_group" "rds" {
  name   = "${var.name}-postgres"
  vpc_id = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "${var.name}-postgres" }
}

# rules
resource "aws_security_group_rule" "cidr" {
  count             = length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = var.allowed_cidr_blocks
}

