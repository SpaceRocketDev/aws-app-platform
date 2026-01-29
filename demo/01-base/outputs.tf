output "base" {
  description = "All base primitives as a single object for downstream stacks via remote state."
  value = {
    org         = var.org
    project     = var.project
    env         = var.env
    aws_region  = var.aws_region
    name_prefix = local.name_prefix
    common_tags = local.common_tags
  }
}
