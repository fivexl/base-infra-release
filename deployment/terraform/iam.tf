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
