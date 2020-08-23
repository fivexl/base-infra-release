module "release_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "1.12.0"

  bucket = local.release_bucket_name
  acl    = "private"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  restrict_public_buckets = true
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = module.release_bucket.this_s3_bucket_bucket_regional_domain_name
    origin_id   = format("S3-%s", module.release_bucket.this_s3_bucket_bucket_regional_domain_name)
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "FivexL releases"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = module.logging_bucket.this_s3_bucket_bucket_domain_name
    prefix          = format("cloudfront-%s", module.release_bucket.this_s3_bucket_id)
  }

  aliases = ["releases.fivexl.io"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = format("S3-%s", module.release_bucket.this_s3_bucket_bucket_regional_domain_name)

    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }

    #path_pattern = "*"

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.releases.arn
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method       = "sni-only"
  }
}

data "aws_acm_certificate" "releases" {
  provider    = aws.us_east_1
  domain      = "releases.fivexl.io"
  statuses    = ["ISSUED"]
  most_recent = true
}