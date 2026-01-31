output "base" {
  description = "All base primitives as a single object for downstream stacks via remote state."
  value = {
    org        = var.org
    project    = var.project
    env        = var.env
    aws_region = var.aws_region
    account_id = local.account_id

    app_names   = var.app_names
    name_prefix = local.name_prefix
    app_path    = local.app_path

    # Useful for downstream SSM reads and path construction
    path_prefixes   = local.path_prefixes
    path_prefix_map = local.path_prefix_map

    # Useful for IAM policy generation / scoping Parameter Store access
    ssm_secret_path_prefixes   = local.ssm_secret_path_prefixes
    ssm_secret_path_prefix_map = local.ssm_secret_path_prefix_map

    fqdn_map    = local.fqdn_map
    common_tags = local.common_tags
  }
}
