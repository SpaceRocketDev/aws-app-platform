variable "alb_config" {
  type = object({
    account_id                = string
    env                       = string
    project                   = string
    name_prefix               = string
    aws_region                = string
    vpc                       = any
    lb_subnets                = list(any)
    lb_sg                     = any
    lb_ssl_policy             = string
    main_domain               = string
    additional_domains        = list(string)
    logs_enabled              = bool
    logs_prefix               = string
    logs_bucket               = string
    logs_expiration           = number
    logs_bucket_force_destroy = bool
    main_cert_arn             = string
    create_aliases = list(object({
      name = string
      zone = string
    }))
    alarm_sns_topic_name = string
    common_tags          = map(string)
    alb_5xx_threshold    = optional(number, 20)
    target_5xx_threshold = optional(number, 20)
  })

  default = {
    account_id  = ""
    env         = "dev"
    project     = "default"
    name_prefix = "myapp-dev"
    aws_region  = "us-east-1"

    vpc        = null
    lb_subnets = []
    lb_sg      = null

    lb_ssl_policy             = "ELBSecurityPolicy-TLS13-1-3-FIPS-2023-04"
    main_domain               = "example.com"
    additional_domains        = []
    logs_enabled              = true
    logs_prefix               = "dev"
    logs_bucket               = "default-dev-ecs-alb-logs"
    logs_expiration           = 90
    logs_bucket_force_destroy = false
    main_cert_arn             = ""

    create_aliases       = []
    alarm_sns_topic_name = "default-ecs-dev-alerts"
    common_tags = {
      Env       = "dev"
      ManagedBy = "terraform"
      Project   = "default"
    }
    alb_5xx_threshold    = 20
    target_5xx_threshold = 20
  }
}