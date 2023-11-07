module "tags" {
  source            = "fivexl/tag-generator/aws"
  version           = "2.0.0"
  prefix            = "fivexl"
  terraform_managed = "1"
#   terraform_state   = "${local.state_bucket_name}/${local.state_key}"
  environment_name  = "releases"
  data_owner        = "fivexl"
}