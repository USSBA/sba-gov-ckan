data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

resource "aws_cloudfront_distribution" "distribution" {
  aliases             = [local.fqdn_data]
  comment             = "CKAN ${title(terraform.workspace)}"
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = false
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = true
  web_acl_id          = aws_wafv2_web_acl.waf_cloudfront.arn
  tags = {
    "Environment" = terraform.workspace
    "Name"        = "ckan-${terraform.workspace}-cloudfront"
  }

  default_cache_behavior {
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    smooth_streaming       = false
    target_origin_id       = "web"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers = [
        "*",
      ]
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward           = "all"
        whitelisted_names = []
      }
    }
  }

  logging_config {
    bucket          = "${local.account_id}-${local.region}-logs.s3.amazonaws.com"
    include_cookies = true
    prefix          = "cloudfront/ckan/${terraform.workspace}"
  }

  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress                 = false
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
    default_ttl              = local.env.default_ttl
    max_ttl                  = local.env.max_ttl
    min_ttl                  = local.env.min_ttl
    path_pattern             = "/dataset/*/resource/*/download/*"
    smooth_streaming         = false
    target_origin_id         = "web"
    trusted_key_groups       = []
    trusted_signers          = []
    viewer_protocol_policy   = "redirect-to-https"
  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 604800
    max_ttl                = 604800
    min_ttl                = 604800
    path_pattern           = "/dataset/*/resource/*/view/*"
    smooth_streaming       = false
    target_origin_id       = "web"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers = [
        "Host",
      ]
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward = "whitelist"
        whitelisted_names = [
          "auth_tkt",
        ]
      }
    }
  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 604800
    max_ttl                = 604800
    min_ttl                = 604800
    path_pattern           = "/*/dataset/*/resource/*/view/*"
    smooth_streaming       = false
    target_origin_id       = "web"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers = [
        "Host",
      ]
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward = "whitelist"
        whitelisted_names = [
          "auth_tkt",
        ]
      }
    }
  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 604800
    max_ttl                = 604800
    min_ttl                = 604800
    path_pattern           = "/webassets/*"
    smooth_streaming       = false
    target_origin_id       = "web"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers = [
        "Host",
      ]
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 604800
    max_ttl                = 604800
    min_ttl                = 604800
    path_pattern           = "/uploads/admin/*.png"
    smooth_streaming       = false
    target_origin_id       = "web"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers = [
        "Host",
      ]
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 604800
    max_ttl                = 604800
    min_ttl                = 604800
    path_pattern           = "/base/*"
    smooth_streaming       = false
    target_origin_id       = "web"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers = [
        "Host",
      ]
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 604800
    max_ttl                = 604800
    min_ttl                = 604800
    path_pattern           = "/api/i18n/*"
    smooth_streaming       = false
    target_origin_id       = "web"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers = [
        "Host",
      ]
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }

  ordered_cache_behavior {
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT",
    ]
    cache_policy_id = data.aws_cloudfront_cache_policy.caching_disabled.id
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress                 = false
    default_ttl              = 0
    max_ttl                  = 0
    min_ttl                  = 0
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
    path_pattern             = "/api/3/action/*"
    smooth_streaming         = false
    target_origin_id         = "web"
    trusted_key_groups       = []
    trusted_signers          = []
    viewer_protocol_policy   = "redirect-to-https"
  }

  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 604800
    max_ttl                = 604800
    min_ttl                = 604800
    path_pattern           = "/"
    smooth_streaming       = false
    target_origin_id       = "web"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers = [
        "Host",
      ]
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward = "whitelist"
        whitelisted_names = [
          "auth_tkt",
        ]
      }
    }
  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 604800
    max_ttl                = 604800
    min_ttl                = 604800
    path_pattern           = "/about"
    smooth_streaming       = false
    target_origin_id       = "web"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers = [
        "Host",
      ]
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward = "whitelist"
        whitelisted_names = [
          "auth_tkt",
        ]
      }
    }
  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 3600
    max_ttl                = 3600
    min_ttl                = 3600
    path_pattern           = "/dataset/"
    smooth_streaming       = false
    target_origin_id       = "web"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers = [
        "Host",
      ]
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward = "whitelist"
        whitelisted_names = [
          "auth_tkt",
        ]
      }
    }
  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 3600
    max_ttl                = 3600
    min_ttl                = 3600
    path_pattern           = "/dataset"
    smooth_streaming       = false
    target_origin_id       = "web"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers = [
        "Host",
      ]
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward = "whitelist"
        whitelisted_names = [
          "auth_tkt",
        ]
      }
    }
  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 3600
    max_ttl                = 3600
    min_ttl                = 3600
    path_pattern           = "/*/dataset/"
    smooth_streaming       = false
    target_origin_id       = "web"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers = [
        "Host",
      ]
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward = "whitelist"
        whitelisted_names = [
          "auth_tkt",
        ]
      }
    }
  }
  ordered_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = false
    default_ttl            = 3600
    max_ttl                = 3600
    min_ttl                = 3600
    path_pattern           = "/*/dataset"
    smooth_streaming       = false
    target_origin_id       = "web"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers = [
        "Host",
      ]
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward = "whitelist"
        whitelisted_names = [
          "auth_tkt",
        ]
      }
    }
  }

  origin {
    connection_attempts = 3
    connection_timeout  = 10
    domain_name         = local.fqdn_web
    origin_id           = "web"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 60
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["RU", "HK", "CN", "IR"] #Russia, Hong Kong, China, Iran
    }
  }

  viewer_certificate {
    acm_certificate_arn            = data.aws_acm_certificate.ssl.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.1_2016"
    ssl_support_method             = "sni-only"
  }
}

# TODO:
# This bucket needs to be removed from the state. After CKAN 2.10 is operational in staging & production this will be cleaned up.
#resource "aws_s3_bucket" "cloudfront_logs" {
#  bucket = "${local.env.domain_name}-${local.env.name}-cloudfront-logs"
#
#  lifecycle {
#    ignore_changes = [
#      grant, # Managed by CloudFront; ignore the changes
#    ]
#  }
#}
