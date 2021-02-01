resource "aws_iam_user" "ci" {
  name = "release-to-s3"
}

resource "aws_iam_access_key" "ci" {
  user = aws_iam_user.ci.name
}

resource "aws_iam_group" "ci" {
  name = "CI"
}

resource "aws_iam_user_group_membership" "ci" {
  groups = [aws_iam_group.ci.name]
  user   = aws_iam_user.ci.name
}

resource "aws_iam_policy" "s3" {
  name        = "AllowPut"
  description = "Allow uploading to release bucket"
  policy      = data.aws_iam_policy_document.s3.json
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid = "AllowPut"

    actions = [
      "s3:ListObjectsV2",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      module.release_bucket.this_s3_bucket_arn,
      "${module.release_bucket.this_s3_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_group_policy_attachment" "s3" {
  group      = aws_iam_group.ci.name
  policy_arn = aws_iam_policy.s3.arn
}

data "aws_iam_policy_document" "ci" {
  statement {
    sid    = "Allow"
    effect = "Allow"
    actions = [
      "lambda:*",
      "cloudfront:*",
      "sns:*",
      "cloudwatch:*",
      "cloudformation:*",
      "iam:GetUser",
      "iam:GetGroup",
      "iam:ListGroupsForUser",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:GetRole",
      "iam:ListAccessKeys",
      "iam:ListAttachedGroupPolicies",
      "iam:ListEntitiesForPolicy",
      "iam:ListAttachedRolePolicies",
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "acm:ListTagsForCertificate",
      "logs:DescribeLogGroups",
      "logs:ListTagsLogGroup",
      "s3:PutAnalyticsConfiguration",
      "s3:GetObjectVersionTagging",
      "s3:DeleteAccessPoint",
      "s3:CreateBucket",
      "s3:GetObjectAcl",
      "s3:GetBucketObjectLockConfiguration",
      "s3:DeleteBucketWebsite",
      "s3:PutLifecycleConfiguration",
      "s3:GetObjectVersionAcl",
      "s3:PutBucketAcl",
      "s3:PutObjectTagging",
      "s3:HeadBucket",
      "s3:GetBucketPolicyStatus",
      "s3:GetObjectRetention",
      "s3:GetBucketWebsite",
      "s3:GetJobTagging",
      "s3:ListJobs",
      "s3:PutReplicationConfiguration",
      "s3:PutObjectLegalHold",
      "s3:GetObjectLegalHold",
      "s3:GetBucketNotification",
      "s3:PutBucketCORS",
      "s3:GetReplicationConfiguration",
      "s3:ListMultipartUploadParts",
      "s3:PutBucketNotification",
      "s3:DescribeJob",
      "s3:PutBucketLogging",
      "s3:PutObjectVersionAcl",
      "s3:GetAnalyticsConfiguration",
      "s3:PutBucketObjectLockConfiguration",
      "s3:GetObjectVersionForReplication",
      "s3:CreateJob",
      "s3:CreateAccessPoint",
      "s3:GetLifecycleConfiguration",
      "s3:GetAccessPoint",
      "s3:GetInventoryConfiguration",
      "s3:GetBucketTagging",
      "s3:PutAccelerateConfiguration",
      "s3:GetBucketLogging",
      "s3:ListBucketVersions",
      "s3:ReplicateTags",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketPolicy",
      "s3:PutEncryptionConfiguration",
      "s3:GetEncryptionConfiguration",
      "s3:GetObjectVersionTorrent",
      "s3:AbortMultipartUpload",
      "s3:PutBucketTagging",
      "s3:GetBucketRequestPayment",
      "s3:GetAccessPointPolicyStatus",
      "s3:GetObjectTagging",
      "s3:GetMetricsConfiguration",
      "s3:PutBucketVersioning",
      "s3:PutObjectAcl",
      "s3:GetBucketPublicAccessBlock",
      "s3:ListBucketMultipartUploads",
      "s3:PutBucketPublicAccessBlock",
      "s3:ListAccessPoints",
      "s3:PutMetricsConfiguration",
      "s3:PutObjectVersionTagging",
      "s3:PutJobTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketAcl",
      "s3:PutInventoryConfiguration",
      "s3:GetObjectTorrent",
      "s3:GetAccountPublicAccessBlock",
      "s3:PutBucketWebsite",
      "s3:ListAllMyBuckets",
      "s3:PutBucketRequestPayment",
      "s3:PutObjectRetention",
      "s3:GetBucketCORS",
      "s3:PutBucketPolicy",
      "s3:GetBucketLocation",
      "s3:GetAccessPointPolicy",
      "s3:GetObjectVersion"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "Deny"
    effect = "Deny"
    actions = [
      "lambda:InvokeFunction",
      "lambda:InvokeAsync"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "ci" {
  name        = "AllowForCI"
  description = "Access for CI"
  policy      = data.aws_iam_policy_document.ci.json
}

resource "aws_iam_group_policy_attachment" "ci" {
  group      = aws_iam_group.ci.name
  policy_arn = aws_iam_policy.ci.arn
}

data "aws_iam_policy_document" "s3_state" {
  statement {
    sid    = "AllowPutState"
    effect = "Allow"
    actions = [
      "s3:ListObjectsV2",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject"
    ]
    resources = [
      "${module.state_bucket.this_s3_bucket_arn}",
      "${module.state_bucket.this_s3_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_state" {
  name        = "AllowPutState"
  description = "Allow uploading to state bucket"
  policy      = data.aws_iam_policy_document.s3_state.json
}

resource "aws_iam_group_policy_attachment" "s3_state" {
  group      = aws_iam_group.ci.name
  policy_arn = aws_iam_policy.s3_state.arn
}

data "aws_iam_policy_document" "s3_logs" {
  statement {
    sid    = "AllowListLogs"
    effect = "Allow"
    actions = [
      "s3:ListObjectsV2",
      "s3:ListBucket"
    ]
    resources = [
      "${module.logging_bucket.this_s3_bucket_arn}",
      "${module.logging_bucket.this_s3_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_logs" {
  name        = "AllowListLogs"
  description = "Allow list logs bucket"
  policy      = data.aws_iam_policy_document.s3_logs.json
}

resource "aws_iam_group_policy_attachment" "s3_logs" {
  group      = aws_iam_group.ci.name
  policy_arn = aws_iam_policy.s3_logs.arn
}

# IAM for Lambda Release Index Generator
data "aws_iam_policy_document" "lambda_release_index_generator_s3" {
  statement {
    sid = "AllowGet"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      module.release_bucket.this_s3_bucket_arn,
      "${module.release_bucket.this_s3_bucket_arn}/*"
    ]
  }
  statement {
    sid = "AllowPutIndex"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "${module.release_bucket.this_s3_bucket_arn}/index.html",
      "${module.release_bucket.this_s3_bucket_arn}/*index.html",
    ]
  }
}

resource "aws_iam_policy" "lambda_release_index_generator_s3" {
  name        = "LambdaReleasesIndexAllowGetAndPutIndex"
  description = "Allow get objects from release bucket and upload index.html files to release bucket"
  policy      = data.aws_iam_policy_document.lambda_release_index_generator_s3.json
}

resource "aws_iam_role_policy_attachment" "lambda_release_index_generator_s3" {
  role       = module.lambda_release_index_generator.lambda_role_name
  policy_arn = aws_iam_policy.lambda_release_index_generator_s3.arn
}
