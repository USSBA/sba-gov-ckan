# module variables
variable "name" {
  type        = string
  description = "The EFS name."
}
variable "mount_target_subnet_ids" {
  type        = list(string)
  description = "A list of `subnet_id` where the EFS will be mounted."
}
variable "vpc_id" {
  type        = string
  description = "The `vpc_id` where the EFS will be provisioned."
}
variable "allowed_security_group_ids" {
  type        = list(string)
  description = "A list of `security_group_id` will be used to make EFS connections."
  default     = []
}
variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "A list of cidr_blocks that will be allowed to mount"
  default     = []
}
variable "tags" {
  type        = map(any)
  description = "A map of additional resource tags."
  default     = {}
}
variable "efs_tags" {
  type        = map(any)
  description = "A map of additional tags specifically for EFS volumes."
  default     = {}
}
# efs
resource "aws_efs_file_system" "this" {
  encrypted = true
  tags      = merge(var.tags, var.efs_tags, { Name = var.name })
}

# mount targets
resource "aws_efs_mount_target" "this" {
  for_each        = toset(var.mount_target_subnet_ids)
  file_system_id  = aws_efs_file_system.this.id
  security_groups = [aws_security_group.this.id]
  subnet_id       = each.value
}

# security group
resource "aws_security_group" "this" {
  name   = "${var.name}-efs"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.name}-efs" })

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
resource "aws_security_group_rule" "cidr" {
  count             = length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.this.id
}
resource "aws_security_group_rule" "group" {
  for_each                 = toset(var.allowed_security_group_ids)
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.this.id
}

# module outputs
output "id" {
  value = aws_efs_file_system.this.id
}
output "arn" {
  value = aws_efs_file_system.this.arn
}
output "dns_name" {
  value = aws_efs_file_system.this.dns_name
}
output "security_group_id" {
  value = aws_security_group.this.id
}
