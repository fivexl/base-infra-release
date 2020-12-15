module "logging_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "1.12.0"

  bucket = local.logging_bucket_name
  acl    = "log-delivery-write"

  versioning = {
    enabled = true
  }

  logging = {
    target_bucket = local.logging_bucket_name
    target_prefix = local.logging_bucket_name
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