data "aws_vpc" "ckan" {
  tags = {
    Name = "ckan-${terraform.workspace}"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.ckan.id]
  }
  filter {
    name = "tag:Name"
    values = [
      "ckan-${terraform.workspace}-private-*"
    ]
  }
}

