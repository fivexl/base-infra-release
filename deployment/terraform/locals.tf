locals {
  state_bucket_name   = format("terraform-state-%s", sha1(data.aws_caller_identity.current.account_id))
  logging_bucket_name = format("access-logs-%s", sha1(data.aws_caller_identity.current.account_id))
  release_bucket_name = format("release-%s", sha1(data.aws_caller_identity.current.account_id))
  emails_parameter    = "/cloudfront/notification_emails"
}