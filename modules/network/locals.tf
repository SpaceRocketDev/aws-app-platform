locals {
  name_prefix = var.network_config.name_prefix
  common_tags = var.network_config.common_tags
  natgw_count = var.network_config.natgw_count == "all" ? var.network_config.az_num : (var.network_config.natgw_count == "one" ? 1 : 0)
}
