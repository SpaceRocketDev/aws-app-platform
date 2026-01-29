locals {
  base        = data.terraform_remote_state.base.outputs.base
  name_prefix = local.base.name_prefix
  project     = local.base.project
  topic_name  = "${local.base.name_prefix}-ecs-alerts"
  env         = local.base.env
  aws_region  = local.base.aws_region
  common_tags = local.base.common_tags
}
