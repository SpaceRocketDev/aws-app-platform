locals {
  # name_prefix = format("%s-%s", var.project, var.env)
  # alb_name    = format("%s-%s", local.name_prefix, "alb")
  name_prefix = var.alb_config.name_prefix
  common_tags = var.alb_config.common_tags
  natgw_count = var.alb_config.natgw_count

  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html#attach-bucket-policy
  lb_account_id = lookup({
    "us-east-1"    = "127311923021"
    "us-west-1"    = "027434742980"
    "us-west-2"    = "797873946194"
    },
    var.alb_config.aws_region
  )
}
