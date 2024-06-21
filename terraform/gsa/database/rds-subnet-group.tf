resource "aws_db_subnet_group" "ckan" {
  name       = "ckan-${terraform.workspace}"
  subnet_ids = data.aws_subnets.ckan_private.ids
}
