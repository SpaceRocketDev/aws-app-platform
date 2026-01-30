output "base" {
  description = "All base primitives as a single object for downstream stacks via remote state."
  value = {
    org                      = var.org
    project                  = var.project
    env                      = var.env
    aws_region               = var.aws_region
    name_prefix              = local.name_prefix
    app_path                 = local.app_path
    common_tags              = local.common_tags
    ssm_secret_path_prefixes = local.ssm_secret_path_prefixes
  }
}
