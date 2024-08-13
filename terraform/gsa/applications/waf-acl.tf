resource "aws_wafv2_web_acl" "waf_cloudfront" {
  name        = "${terraform.workspace}-ckan-cloudfront-acl"
  description = "${terraform.workspace}-ckan-cloudfront-acl"
  scope       = "CLOUDFRONT"

  dynamic "default_action" {
    for_each = contains(["staging"], terraform.workspace) ? ["ON"] : []
    content {
      allow {}
    }
  }

  dynamic "default_action" {
    for_each = !contains(["staging"], terraform.workspace) ? ["ON"] : []
    content {
      allow {}
    }
  }

  # RATE LIMIT
  # --------------------------------------------------
  rule {
    name     = "rate-limit"
    priority = 0
    action {
      block {}
    }
    statement {
      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = 3500
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit"
      sampled_requests_enabled   = false
    }
  }

  # IPV4 WHITE-LIST
  # ZScaler & Global AT&T VPN
  # --------------------------------------------------

  #dynamic "rule" {
  #  for_each = contains(["staging"], terraform.workspace) ? ["ON"] : []
  #  content {
  #    name     = "${terraform.workspace}-ipv4-whitelist-ips"
  #    priority = 1
  #    action {
  #      allow {}
  #    }
  #    statement {
  #      ip_set_reference_statement {
  #        arn = aws_wafv2_ip_set.ipv4_whitelist[0].arn
  #      }
  #    }
  #    visibility_config {
  #      cloudwatch_metrics_enabled = true
  #      metric_name                = "${terraform.workspace}-ipv4-whitelist-ips"
  #      sampled_requests_enabled   = true
  #    }
  #  }
  #}

  ## IPV6 WHITE-LIST
  ## ZScaler & Global AT&T VPN
  ## --------------------------------------------------
  #dynamic "rule" {
  #  for_each = contains(["staging"], terraform.workspace) ? ["ON"] : []
  #  content {
  #    name     = "${terraform.workspace}-ipv6-whitelist-ips"
  #    priority = 2
  #    action {
  #      allow {}
  #    }
  #    statement {
  #      ip_set_reference_statement {
  #        arn = aws_wafv2_ip_set.ipv6_whitelist[0].arn
  #      }
  #    }
  #    visibility_config {
  #      cloudwatch_metrics_enabled = true
  #      metric_name                = "${terraform.workspace}-ipv6-whitelist-ips"
  #      sampled_requests_enabled   = true
  #    }
  #  }
  #}

  # VISIBILITY CONFIGURATION
  # For the ACL itself.
  # --------------------------------------------------
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${terraform.workspace}-ckan-cloudfront-acl"
    sampled_requests_enabled   = false
  }
}

