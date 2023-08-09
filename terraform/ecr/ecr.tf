resource "aws_ecr_repository" "ckan" {
  name = "ckan"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "ckan_datapusher" {
  name = "ckan-datapusher"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "ckan_solr" {
  name = "ckan-solr"

  image_scanning_configuration {
    scan_on_push = false
  }
}
