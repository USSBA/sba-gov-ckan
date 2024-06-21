resource "aws_ecr_repository" "ckan" {
  name = "gsa-ckan"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "ckan_solr" {
  name = "gsa-ckan-solr"

  image_scanning_configuration {
    scan_on_push = false
  }
}
