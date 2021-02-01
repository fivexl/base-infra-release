data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "releases" {
  provider    = aws.us_east_1
  domain      = "releases.fivexl.io"
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_ssm_parameter" "emails" {
  name = local.emails_parameter
}

data "template_file" "aws_cf_sns_cf_releases_stack" {
  template = file("${path.module}/templates/cf_aws_sns_email_stack.json.tpl")
  vars = {
    RESOURCE_NAME = "CFRELEASESALERTS"
    TOPIC_NAME    = "CloudFront_FivexL_Releases_Alerts"
    DISPLAY_NAME  = "FivexL_Releases_Alerts"
    SNS_SUB_LIST  = join(",", formatlist("{\"Endpoint\": \"%s\",\"Protocol\": \"%s\"}", split(",", data.aws_ssm_parameter.emails.value), "email"))
  }
}

data "aws_sns_topic" "cf_releases_alerts" {
  provider   = aws.us_east_1
  name       = "CloudFront_FivexL_Releases_Alerts"
  depends_on = [aws_cloudformation_stack.tf_sns_cf_releases_topic]
}