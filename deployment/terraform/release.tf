module "release_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.9.0"

  bucket = local.release_bucket_name
  acl    = "private"

  versioning = {
    enabled = true
  }

  website = {
    index_document = "index.html"
    error_document = "error.html"
  }

  logging = {
    target_bucket = module.logging_bucket.s3_bucket_id
    target_prefix = local.release_bucket_name
  }

  cors_rule = [
    {
      allowed_methods = ["GET"]
      allowed_origins = ["https://releases.fivexl.io"]
      allowed_headers = ["*"]
      max_age_seconds = 3000
    }
  ]

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  attach_policy                         = true
  attach_deny_insecure_transport_policy = true
  policy                                = data.aws_iam_policy_document.release_bucket_policy.json

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

data "aws_iam_policy_document" "release_bucket_policy" {
  statement {
    sid = "AllowCloudFrontReadObjects"

    actions = [
      "s3:GetObject"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.release.iam_arn]
    }

    resources = [
      "arn:aws:s3:::${local.release_bucket_name}/*",
    ]
  }
}

resource "aws_cloudfront_origin_access_identity" "release" {
  comment = "FivexL Releases CDN"
}


resource "aws_cloudfront_distribution" "s3_distribution" { #tfsec:ignore:AWS045
  origin {
    domain_name = module.release_bucket.s3_bucket_bucket_regional_domain_name
    origin_id   = format("S3-Website-%s", module.release_bucket.s3_bucket_website_endpoint)

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.release.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "FivexL releases"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = module.logging_bucket.s3_bucket_bucket_domain_name
    prefix          = format("cloudfront-%s", module.release_bucket.s3_bucket_id)
  }

  aliases = ["releases.fivexl.io"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = format("S3-Website-%s", module.release_bucket.s3_bucket_website_endpoint)

    forwarded_values {
      cookies {
        forward = "none"
      }
      headers      = ["Origin"]
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
    minimum_protocol_version = "TLSv1.2_2019" #tfsec:ignore:AWS021
    ssl_support_method       = "sni-only"
  }
}

#####################
# CloudFront Alarm + SNS Email notification
#####################

# Email is unsupported protocols for sns_topic_subscription.
# More info: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription
# Here used one way to solve this problem. Create a Cloud Formation Stack and later use it in Terraform
# Also we must use us-east-1 region for Cloud Front
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/programming-cloudwatch-metrics.html

resource "aws_cloudformation_stack" "tf_sns_cf_releases_topic" {
  provider      = aws.us_east_1
  name          = "SNSTopicCFReleases"
  template_body = data.template_file.aws_cf_sns_cf_releases_stack.rendered
  tags = {
    name = "SNSTopicCFReleases"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_releases_bytes_downloaded" {
  provider                  = aws.us_east_1
  alarm_name                = "${aws_cloudfront_distribution.s3_distribution.id}-CF-BytesDownloaded"
  alarm_description         = "CloudFront releases.fivexl.io BytesDownloaded is higher than 100Mb/min. Maybe it denial of wallet attack"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "BytesDownloaded"
  namespace                 = "AWS/CloudFront"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "104857600"
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
  alarm_actions             = [data.aws_sns_topic.cf_releases_alerts.arn]
  datapoints_to_alarm       = 1
  ok_actions = [
      "arn:aws:sns:us-east-1:222341826240:CloudFront_FivexL_Releases_Alerts",
  ]
  dimensions = {
    Region         = "Global"
    DistributionId = aws_cloudfront_distribution.s3_distribution.id
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_releases_requests" {
  provider                  = aws.us_east_1
  alarm_name                = "${aws_cloudfront_distribution.s3_distribution.id}-CF-Requests"
  alarm_description         = "CloudFront releases.fivexl.io Requests is higher than 10000/min. Maybe it denial of wallet attack"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "Requests"
  namespace                 = "AWS/CloudFront"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "10000"
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
  alarm_actions             = [data.aws_sns_topic.cf_releases_alerts.arn]
  datapoints_to_alarm       = 1
  ok_actions = [
      "arn:aws:sns:us-east-1:222341826240:CloudFront_FivexL_Releases_Alerts",
  ]
  dimensions = {
    Region         = "Global"
    DistributionId = aws_cloudfront_distribution.s3_distribution.id
  }
}

# Trigger for Lambda Release Index Generator
# WARNING: Don't remove filter_suffix. Without suffix it will be invocation loop
# TODO: Many runs for one deployment. Because we post many .zip files to S3
resource "aws_s3_bucket_notification" "trigger_index_generator" {
  bucket = module.release_bucket.s3_bucket_id
  lambda_function {
    lambda_function_arn = module.lambda_release_index_generator.lambda_function_arn
    events              = ["s3:ObjectCreated:Post", "s3:ObjectCreated:Put"]
    filter_suffix       = ".zip"
  }
}