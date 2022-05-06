# variables
variable "name" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "hosted_zone_id" {
  type = string
}
variable "fqdn" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "allowed_cidr_blocks" {
  type = list(string)
}
variable "tags" {
  type    = map(any)
  default = {}
}

# subnet group
resource "aws_elasticache_subnet_group" "group" {
  name       = var.name
  subnet_ids = var.subnet_ids
}

# cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id               = var.name
  engine                   = "redis"
  node_type                = "cache.m5.large"
  num_cache_nodes          = 1
  parameter_group_name     = "default.redis5.0"
  engine_version           = "5.0.3"
  port                     = 6379
  maintenance_window       = "sun:05:00-sun:09:00"
  apply_immediately        = true
  snapshot_window          = "00:01-04:00"
  snapshot_retention_limit = 14
  subnet_group_name        = aws_elasticache_subnet_group.group.name
  security_group_ids       = [aws_security_group.redis.id]
}

# dns
resource "aws_route53_record" "redis" {
  zone_id = var.hosted_zone_id
  name    = var.fqdn
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elasticache_cluster.redis.cache_nodes.0.address]
}

# security group
resource "aws_security_group" "redis" {
  name   = "${var.name}-redis"
  vpc_id = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-redis" })
}

# rules
resource "aws_security_group_rule" "cidr" {
  count             = length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = aws_security_group.redis.id
  cidr_blocks       = var.allowed_cidr_blocks
}
