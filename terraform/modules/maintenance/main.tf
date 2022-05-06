variable "fqdn" {
  type = string
}
variable "hosted_zone_id" {
  type = string
}
variable "bucket_name" {
  type = string
}

# website bucket
data "aws_s3_bucket" "website" {
  bucket = var.bucket_name
}

# files
resource "aws_s3_bucket_object" "index" {
  bucket = data.aws_s3_bucket.website.id
  key    = "index.html"
  source = "${path.module}/index.html"
  etag   = filemd5("${path.module}/index.html")
  acl    = "public-read"
}
resource "aws_s3_bucket_object" "logo" {
  bucket = data.aws_s3_bucket.website.id
  key    = "SBA-Logo-Stacked-1Color-White.png"
  source = "${path.module}/SBA-Logo-Stacked-1Color-White.png"
  etag   = filemd5("${path.module}/SBA-Logo-Stacked-1Color-White.png")
  acl    = "public-read"
}

# dns
resource "aws_route53_record" "website" {
  zone_id = var.hosted_zone_id
  name    = var.fqdn
  type    = "A"
  alias {
    name                   = data.aws_s3_bucket.website.website_domain
    zone_id                = data.aws_s3_bucket.website.hosted_zone_id
    evaluate_target_health = false
  }
}

