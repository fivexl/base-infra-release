module "aws_sso_elevator_ecr_eu_central_1" {
  source                                    = "terraform-aws-modules/ecr/aws"
  repository_name                           = "aws-sso-elevator"
  create_lifecycle_policy                   = false
  create_repository_policy                  = false
  repository_policy                         = data.aws_iam_policy_document.ecr.json
  providers                                 = { aws = aws.eu_central_1 }
  create_registry_replication_configuration = true
  registry_replication_rules = [{
    destinations = [
      {
        region      = "us-east-2"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "us-east-1"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "us-west-1"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "us-west-2"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "ap-south-1"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "ap-northeast-3"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "ap-northeast-2"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "ap-southeast-1"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "ap-southeast-2"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "ap-northeast-1"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "ca-central-1"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "eu-west-1"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "eu-west-2"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "eu-west-3"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "eu-north-1"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "sa-east-1"
        registry_id = data.aws_caller_identity.current.account_id
      },
      {
        region      = "eu-south-1"
        registry_id = data.aws_caller_identity.current.account_id
      },
    ]
  }]
}


module "aws_sso_elevator_ecr_us_east_2" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.us_east_2 }
}


module "aws_sso_elevator_ecr_us_east_1" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.us_east_1 }
}


module "aws_sso_elevator_ecr_us_west_1" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.us_west_1 }
}


module "aws_sso_elevator_ecr_us_west_2" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.us_west_2 }
}


module "aws_sso_elevator_ecr_ap_south_1" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.ap_south_1 }
}


module "aws_sso_elevator_ecr_ap_northeast_3" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.ap_northeast_3 }
}


module "aws_sso_elevator_ecr_ap_northeast_2" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.ap_northeast_2 }
}


module "aws_sso_elevator_ecr_ap_southeast_1" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.ap_southeast_1 }
}


module "aws_sso_elevator_ecr_ap_southeast_2" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.ap_southeast_2 }
}


module "aws_sso_elevator_ecr_ap_northeast_1" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.ap_northeast_1 }
}


module "aws_sso_elevator_ecr_ca_central_1" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.ca_central_1 }
}


module "aws_sso_elevator_ecr_eu_west_1" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.eu_west_1 }
}


module "aws_sso_elevator_ecr_eu_west_2" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.eu_west_2 }
}


module "aws_sso_elevator_ecr_eu_west_3" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.eu_west_3 }
}


module "aws_sso_elevator_ecr_eu_north_1" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.eu_north_1 }
}


module "aws_sso_elevator_ecr_sa_east_1" {
  source                   = "terraform-aws-modules/ecr/aws"
  repository_name          = "aws-sso-elevator"
  create_lifecycle_policy  = false
  create_repository_policy = false
  repository_policy        = data.aws_iam_policy_document.ecr.json
  providers                = { aws = aws.sa_east_1 }
}


data "aws_iam_policy_document" "ecr" {
  statement {
    sid    = "CrossAccountPermission"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_user" "ecr_ci" {
  name = "push_images_to_ecr"
}

resource "aws_iam_access_key" "ecr_ci" {
  user = aws_iam_user.ecr_ci.name
}

resource "aws_iam_group" "ecr_ci" {
  name = "ecr_ci"
}

resource "aws_iam_user_group_membership" "ecr_ci" {
  groups = [aws_iam_group.ecr_ci.name]
  user   = aws_iam_user.ecr_ci.name
}

resource "aws_iam_group_policy_attachment" "ecr_ci" {
  group      = aws_iam_group.ecr_ci.name
  policy_arn = aws_iam_policy.ecr_ci.arn
}

resource "aws_iam_policy" "ecr_ci" {
  name        = "AllowPushToECR"
  description = "Allow pushing images to ECR for SSO Elevator"
  policy      = data.aws_iam_policy_document.ecr_ci.json
}

data "aws_iam_policy_document" "ecr_ci" {
  statement {
    sid    = "Allow"
    effect = "Allow"
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
    ]
    resources = [
      module.aws_sso_elevator_ecr_eu_central_1.repository_arn
    ]
  }
  statement {
    sid    = "AllowGetAuthorizationToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
}



