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

#####################
# CloudFront Alarm + SNS Email notification
#####################

# Email is unsupported protocols for sns_topic_subscription.
# More info: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription
# Here used one way to solve this problem. Create a Cloud Formation Stack and later use it in Terraform
# Also we must use us-east-1 region for Cloud Front
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/programming-cloudwatch-metrics.html

data "template_file" "aws_cf_sns_cf_releases_stack" {
  template = file("${path.module}/templates/cf_aws_sns_email_stack.json.tpl")
  vars = {
    RESOURCE_NAME = "CFRELEASESALERTS"
    TOPIC_NAME    = "CloudFront_FivexL_Releases_Alerts"
    DISPLAY_NAME  = "FivexL_Releases_Alerts"
    SNS_SUB_LIST  = join(",", formatlist("{\"Endpoint\": \"%s\",\"Protocol\": \"%s\"}", local.email_address_list, "email"))
  }
}

resource "aws_cloudformation_stack" "tf_sns_cf_releases_topic" {
  provider      = aws.us_east_1
  name          = "SNSTopicCFReleases"
  template_body = data.template_file.aws_cf_sns_cf_releases_stack.rendered
  tags = {
    name = "SNSTopicCFReleases"
  }
}

data "aws_sns_topic" "cf_releases_alerts" {
  provider   = aws.us_east_1
  name       = "CloudFront_FivexL_Releases_Alerts"
  depends_on = [aws_cloudformation_stack.tf_sns_cf_releases_topic]
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
  ok_actions                = []
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
  ok_actions                = []
  dimensions = {
    Region         = "Global"
    DistributionId = aws_cloudfront_distribution.s3_distribution.id
  }
}