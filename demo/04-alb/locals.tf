locals {
  base        = data.terraform_remote_state.base.outputs.base
  name_prefix = local.base.name_prefix
  app_path    = local.base.app_path
  project     = local.base.project
  env         = local.base.env
  aws_region  = local.base.aws_region
  common_tags = local.base.common_tags

  network           = data.terraform_remote_state.network.outputs.network
  vpc               = local.network.vpc
  subnets_public    = local.network.public_subnet_ids
  nat_gateway_eips  = local.network.nat_gateway_eips
  natgw_count       = local.network.natgw_count    
  
  sns               = data.terraform_remote_state.sns.outputs.sns
  sns_topic_arn     = local.sns.sns_topic_arn
  sns_topic_name    = local.sns.sns_topic_name

  logs_bucket = "${local.name_prefix}-alb-logs"

  fqdn_map = {
    for app in var.app_names :
    app != "" ? app : "root" => app != "" ? "${app}.${var.base_domain}" : var.base_domain
  }

  public_ips_v6 = {}
}
