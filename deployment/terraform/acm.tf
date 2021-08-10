# Would be nice to generate validation records via Terraform
# but that would require to move DNS management to Route53 first
resource "aws_acm_certificate" "release" {
  provider          = aws.us_east_1
  domain_name       = "releases.fivexl.io"
  validation_method = "DNS"

  lifecycle {
    prevent_destroy = true
  }
}