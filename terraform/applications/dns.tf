resource "aws_route53_record" "cloudfront" {
  zone_id = local.env.hosted_zone_id
  name    = local.fqdn_cloudfront
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "domain" {
  zone_id = local.env.hosted_zone_id
  name    = local.env.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

