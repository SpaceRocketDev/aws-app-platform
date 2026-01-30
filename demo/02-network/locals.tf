locals {
  base        = data.terraform_remote_state.base.outputs.base
  name_prefix = local.base.name_prefix
  project     = local.base.project
  env         = local.base.env
  aws_region  = local.base.aws_region
  common_tags = local.base.common_tags

  network_config = {
    account_id = data.aws_caller_identity.current.account_id
    project    = local.project
    aws_region = local.aws_region
    az_num              = 3
    vpc_ip_block        = "172.27.72.0/22"
    subnet_cidr_private = "172.27.72.0/24"
    subnet_cidr_public  = "172.27.73.0/24"
    new_bits_private    = 2
    new_bits_public     = 2
    name_prefix = local.name_prefix
    natgw_count = var.natgw_count

    common_tags = local.common_tags
  }
}
