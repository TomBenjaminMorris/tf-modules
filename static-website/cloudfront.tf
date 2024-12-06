locals {
  s3_origin_id = "myS3Origin"
}

############ www distribution ############

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = var.domain_name
  description                       = ""
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_response_headers_policy" "www_s3" {
  name = "${var.project_name}-headers-policy"

  remove_headers_config {
    items {
      header = "server"
    }
  }

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      override                   = true
      preload                    = true
    }
  }
}

#tfsec:ignore:aws-cloudfront-enable-waf
#tfsec:ignore:aws-cloudfront-enable-logging
resource "aws_cloudfront_distribution" "www_s3_distribution" {
  #checkov:skip=CKV_AWS_68:No need for WAF
  #checkov:skip=CKV2_AWS_47:No need for WAF
  #checkov:skip=CKV_AWS_86:No need for access logging
  #checkov:skip=CKV_AWS_310:No need for origin failover
  #checkov:skip=CKV_AWS_374:Geo restrictions are set at the client level
  origin {
    domain_name              = aws_s3_bucket.www_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "www.${var.domain_name}"
  default_root_object = "index.html"
  aliases             = ["www.${var.domain_name}"]

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = local.s3_origin_id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.www_s3.id

    forwarded_values {
      query_string = var.forward_query_string

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 31536000
    default_ttl            = 31536000
    max_ttl                = 31536000
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = length(var.allowed_locations) > 0 ? "whitelist" : "none"
      locations        = var.allowed_locations
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = var.common_tags
}

############ Redirection distribution ############

resource "aws_cloudfront_response_headers_policy" "root_s3" {
  name = "${var.project_name}-headers-policy-root"

  remove_headers_config {
    items {
      header = "server"
    }
  }

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      override                   = true
      preload                    = true
    }
  }
}

#tfsec:ignore:aws-cloudfront-enable-waf
#tfsec:ignore:aws-cloudfront-enable-logging
resource "aws_cloudfront_distribution" "root_s3_distribution" {
  #checkov:skip=CKV_AWS_68:No need for WAF
  #checkov:skip=CKV2_AWS_47:No need for WAF
  #checkov:skip=CKV_AWS_86:No need for access logging
  #checkov:skip=CKV2_AWS_46:No need for origin access control
  #checkov:skip=CKV_AWS_310:No need for origin failover
  #checkov:skip=CKV_AWS_305:No need for default root object
  #checkov:skip=CKV_AWS_374:Geo restrictions are set at the client level
  origin {
    domain_name = aws_s3_bucket.root_bucket.website_endpoint
    origin_id   = "S3-.${aws_s3_bucket.root_bucket.bucket}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = var.domain_name
  aliases         = [var.domain_name]

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = "S3-.${aws_s3_bucket.root_bucket.bucket}"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.root_s3.id

    forwarded_values {
      query_string = var.forward_query_string

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 31536000
    default_ttl            = 31536000
    max_ttl                = 31536000
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = length(var.allowed_locations) > 0 ? "whitelist" : "none"
      locations        = var.allowed_locations
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = var.common_tags
}
