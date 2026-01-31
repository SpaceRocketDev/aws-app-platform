# variables.tf (add the missing attributes)
variable "target_group_config" {
  type = object({
    name_prefix                      = string
    tg_name                          = string
    tg_port                          = number
    tg_protocol                      = string
    vpc_id                           = string
    deregistration_delay             = number
    health_check_port                = string
    health_check_protocol            = string
    health_check_enabled             = bool
    health_check_interval            = number
    health_check_path                = string
    health_check_timeout             = number
    health_check_threshold           = number
    health_check_unhealthy_threshold = number
    health_check_matcher             = string

    # listener rule inputs
    listener_443_arn = string
    priority         = number
    host_headers     = list(string)

    # alarms
    alb_arn_suffix           = string
    alarm_sns_topic_arn      = string
  })

  default = {
    name_prefix                      = "myapp-dev"
    tg_name                          = "app"
    tg_port                          = 80
    tg_protocol                      = "HTTP"
    vpc_id                           = ""
    deregistration_delay             = 300
    health_check_port                = "traffic-port"
    health_check_protocol            = "HTTP"
    health_check_enabled             = true
    health_check_interval            = 30
    health_check_path                = "/"
    health_check_timeout             = 5
    health_check_threshold           = 3
    health_check_unhealthy_threshold = 2
    health_check_matcher             = "200-399"

    listener_443_arn = ""
    priority         = 100
    host_headers     = ["example.com"]

    alb_arn_suffix          = ""
    alarm_sns_topic_arn     = ""
  }
}

variable "create_listener_rule" {
  type    = bool
  default = true
}