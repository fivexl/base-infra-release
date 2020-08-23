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
  name        = "Allow-Put"
  description = "Allow uploading to release bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": ["${module.release_bucket.this_s3_bucket_arn}", "${module.release_bucket.this_s3_bucket_arn}:*"]
    }
  ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "s3" {
  group      = aws_iam_group.ci.name
  policy_arn = aws_iam_policy.s3.arn
}
