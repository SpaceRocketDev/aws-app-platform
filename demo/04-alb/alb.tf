module "alb" {
  source = "../../modules/alb"

  alb_config = {
    account_id                = local.account_id
    env                       = local.env
    project                   = local.project
    name_prefix               = local.name_prefix
    aws_region                = local.aws_region
    vpc                       = local.vpc
    lb_subnets                = local.subnets_public
    lb_sg                     = "deprecating"
    lb_ssl_policy             = "ELBSecurityPolicy-TLS13-1-3-FIPS-2023-04"
    main_domain               = var.base_domain
    additional_domains        = values(local.fqdn_map)
    logs_enabled              = true
    logs_prefix               = local.env
    logs_bucket               = "${local.logs_bucket}"
    logs_expiration           = 90
    logs_bucket_force_destroy = false
    alb_5xx_threshold         = 20
    target_5xx_threshold      = 20

    main_cert_arn = var.cert_arn

    create_aliases = [
      for app, fqdn in local.fqdn_map : {
        name = fqdn
        zone = var.base_domain
      }
    ]

    common_tags         = local.common_tags
    alarm_sns_topic_arn = local.sns_topic_arn
    nat_gateway_eips    = local.nat_gateway_eips
    natgw_count         = local.natgw_count

    public_ips = {
      for ip in var.allowed_ips :
      "${ip}/32" => "Allowed IP"
      if !can(regex("/", ip))
    }
    public_ips_v6 = {}

    enable_waf = var.enable_waf
  }
}
