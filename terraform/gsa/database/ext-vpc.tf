data "aws_vpc" "ckan" {
  tags = {
    Name = "ckan-${terraform.workspace}"
  }
}
