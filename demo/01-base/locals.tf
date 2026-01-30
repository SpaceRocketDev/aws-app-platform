locals {
  name_prefix = "${var.org}-${var.project}-${var.env}"
  app_path    = "${var.org}/${var.project}/${var.env}"
  ssm_secret_path_prefixes = [
    for app in var.app_names :
    "arn:aws:ssm:${var.aws_region}:${local.account_id}:parameter/${local.app_path}/${app}"
  ]
  common_tags = merge(
    {
      Org     = var.org
      Project = var.project
      Env     = var.env
    },
    var.extra_tags
  )
}
