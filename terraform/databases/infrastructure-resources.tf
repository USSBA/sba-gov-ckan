data "aws_vpc" "ckan" {
  tags = {
    Name = "ckan-${terraform.workspace}"
  }
}

# subnet ids
data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.ckan.id
  filter {
    name = "tag:Name"
    values = [
      "ckan-${terraform.workspace}-private-*"
    ]
  }
}
