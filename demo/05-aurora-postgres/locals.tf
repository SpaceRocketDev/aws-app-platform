locals {
  base    = data.terraform_remote_state.base.outputs.base
  network = data.terraform_remote_state.network.outputs.network

  name_prefix = local.base.name_prefix
  common_tags = local.base.common_tags
}
