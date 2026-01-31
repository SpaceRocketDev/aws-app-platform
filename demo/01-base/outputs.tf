output "base" {
  description = "All base primitives as a single object for downstream stacks via remote state."
  value = {
    org        = var.org
    project    = var.project
    env        = var.env
    aws_region = var.aws_region
    account_id = local.account_id
    app_names  = var.app_names

    name_prefix = local.name_prefix
    app_path    = local.app_path

    path_prefixes = local.path_prefixes
    path_prefix_map = local.path_prefix_map

    # Path prefixes (for GetParametersByPath)
    ssm_secret_path_prefixes    = local.ssm_secret_path_prefixes
    ssm_secret_path_prefix_map  = local.ssm_secret_path_prefix_map

    # ARN prefixes (for IAM/policies if needed)
    ssm_secret_path_arn_prefixes   = local.ssm_secret_path_arn_prefixes
    ssm_secret_path_arn_prefix_map = local.ssm_secret_path_arn_prefix_map

    fqdn_map     = local.fqdn_map
    common_tags  = local.common_tags
  }
}
