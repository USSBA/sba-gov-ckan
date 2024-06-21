data "aws_ecs_cluster" "cluster" {
  cluster_name = "ckan-${terraform.workspace}"
}

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
    name   = "tag:Name"
    values = ["ckan-${terraform.workspace}-private*"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.ckan.id]
  }
  filter {
    name   = "tag:Name"
    values = ["ckan-${terraform.workspace}-public*"]
  }
}
