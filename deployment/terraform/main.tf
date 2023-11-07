terraform {
  backend "s3" {
    bucket = "terraform-state-013803cc9fe0903d4c12dd9f8cb67f668d589098"
    region = "eu-central-1"
    key    = "base-infra-release/terraform.tfstate"
  }
}

# This is state bucket used above
module "state_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.6.0"

  bucket = local.state_bucket_name
  acl    = "private"

  versioning = {
    enabled = true
  }

  logging = {
    target_bucket = module.logging_bucket.s3_bucket_id
    target_prefix = local.state_bucket_name
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


# S3 for terraform modules
module "terraform_modules_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket        = local.terraform_modules_bucket_name
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  attach_policy = true
  policy        = data.aws_iam_policy_document.s3_tf_modules.json

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

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = module.tags.result
}

data "aws_iam_policy_document" "s3_tf_modules" {
  statement {
    sid = "AllowReadFromAllAccounts"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    # Allow access to tf modules bucket from other AWS accounts
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::315518459988:root", # Artem
        "arn:aws:iam::418656392454:root", # Alexey
      ]
    }
    resources = [
      "arn:aws:s3:::${local.terraform_modules_bucket_name}",
      "arn:aws:s3:::${local.terraform_modules_bucket_name}/*"
    ]
  }
}

locals {
  terraform_modules_bucket_name       = format("terraform-modules-%s",  sha1(data.aws_caller_identity.current.account_id))
}
