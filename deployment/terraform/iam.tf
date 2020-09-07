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
      "${module.release_bucket.this_s3_bucket_arn}",
      "${module.release_bucket.this_s3_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_group_policy_attachment" "s3" {
  group      = aws_iam_group.ci.name
  policy_arn = aws_iam_policy.s3.arn
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