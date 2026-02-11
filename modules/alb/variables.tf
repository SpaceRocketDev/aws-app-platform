variable "alb_config" {
  type = object({
    account_id                = optional(string, "")
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
    create_aliases            = list(object({
      name = string
      zone = string
    }))
    common_tags            = map(string)
    target_5xx_threshold   = optional(number, 20)
    alb_5xx_threshold      = optional(number, 20)
    alarm_sns_topic_arn    = string

    logs_access_enabled            = optional(bool, true)
    logs_access_bucket             = optional(string, null)
    logs_access_prefix             = optional(string, "s3-access-logs/")
    logs_access_bucket_force_destroy = optional(bool, false)
    logs_access_expiration         = optional(number, 365)
    nat_gateway_eips               = optional(list(string), []) 
    logs_kms_key_arn               = optional(string, null)
    enable_deletion_protection     = optional(bool, true)
    enable_waf                     = optional(bool, true)

    natgw_count = string # "none" | "one" | "all"
    public_ips          = map(string)
    public_ips_v6       = map(string)
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

    create_aliases = []
    common_tags    = { Env = "dev", ManagedBy = "terraform", Project = "default" }
    alb_5xx_threshold    = 20
    target_5xx_threshold = 20
    alarm_sns_topic_arn  = ""

    logs_access_enabled              = true
    logs_access_bucket               = null        # if null, a name will be derived below
    logs_access_prefix               = "s3-access-logs/"
    logs_access_bucket_force_destroy = false
    logs_access_expiration           = 365
    nat_gateway_eips                 = []
    logs_kms_key_arn                 = null
    enable_deletion_protection       = true
    enable_waf                       = true

    natgw_count = "none" # "none" | "one" | "all"
    public_ips          = { "0.0.0.0/0" = "Open" }
    public_ips_v6       = { "::/0" = "Open" }
  }
}
