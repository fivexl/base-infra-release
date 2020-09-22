terraform {
  backend "s3" {
    bucket = "terraform-state-013803cc9fe0903d4c12dd9f8cb67f668d589098"
    region = "eu-central-1"
    key    = "base-infra-release/terraform.tfstate"
  }
}

data "aws_caller_identity" "current" {}

locals {
  state_bucket_name   = format("terraform-state-%s", sha1(data.aws_caller_identity.current.account_id))
  logging_bucket_name = format("access-logs-%s", sha1(data.aws_caller_identity.current.account_id))
  release_bucket_name = format("release-%s", sha1(data.aws_caller_identity.current.account_id))
  email_address_list  = var.em_list
}

# This is state bucket used above
module "state_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "1.12.0"

  bucket = local.state_bucket_name
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

  // S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}