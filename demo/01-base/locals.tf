locals {
  name_prefix = "${var.org}-${var.project}-${var.env}"
  app_path    = "${var.org}/${var.project}/${var.env}"

  path_prefixes = [for app in var.app_names : "/${local.app_path}/${app}"]

  # For aws_ssm_parameters_by_path (must start with "/")
  ssm_secret_path_prefixes = [for app in var.app_names : "/${local.app_path}/${app}"]

  # For IAM policies / explicit ARNs (optional, but useful)
  ssm_secret_path_arn_prefixes = [
    for app in var.app_names :
    "arn:aws:ssm:${var.aws_region}:${local.account_id}:parameter/${local.app_path}/${app}"
  ]

  ssm_secret_path_prefix_map = {
    for idx, app in var.app_names : app => trimsuffix(local.ssm_secret_path_prefixes[idx], "/")
  }

  ssm_secret_path_arn_prefix_map = {
    for idx, app in var.app_names : app => local.ssm_secret_path_arn_prefixes[idx]
  }

  path_prefix_map = {
    for idx, app in var.app_names : app => trimsuffix(local.path_prefixes[idx], "/")
  }

  fqdn_map = {
    for app in var.app_names :
    app != "" ? app : "root" => app != "" ? "${app}.${var.base_domain}" : var.base_domain
  }

  common_tags = merge(
    { Org = var.org, Project = var.project, Env = var.env },
    var.extra_tags
  )
}
