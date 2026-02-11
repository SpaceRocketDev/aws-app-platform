locals {
  name_prefix        = var.aurora_config.name_prefix
  common_tags        = var.aurora_config.common_tags
  cluster_identifier = "${local.name_prefix}-aurora-pg"
  database_name      = replace(var.aurora_config.database_name, "-", "_")
}
