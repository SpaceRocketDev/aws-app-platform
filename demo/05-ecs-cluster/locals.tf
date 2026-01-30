locals {
  base = data.terraform_remote_state.base.outputs.base


  ecs_cluster_config = {
    account_id               = local.account_id
    name_prefix              = local.base.name_prefix
    project                  = local.base.project
    env                      = local.base.env
    aws_region               = local.base.aws_region
    ssm_secret_path_prefixes = local.base.ssm_secret_path_prefixes
    tags                     = local.base.common_tags

    ecs_execution_role_arn = ""
    cluster_name_override  = ""
  }
}
