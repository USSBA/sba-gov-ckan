resource "aws_security_group" "ckan" {
  name        = "ckan-${terraform.workspace}"
  description = "security group for ckan-${terraform.workspace} postgresql databases"
  vpc_id      = data.aws_vpc.ckan.id

  tags = {
    Name = "ckan-${terraform.workspace}"
  }
}
resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.ckan.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "all"
}
