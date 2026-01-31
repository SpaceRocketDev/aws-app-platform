locals {
  target_group_config = merge(
    local.base,
    local.ecs_cluster,
    {
      priority = var.priority
      vpc_id   = local.vpc_id

      tg_name     = "${var.app_name}-blue"
      tg_port     = var.port
      tg_protocol = "HTTP"

      deregistration_delay = 60

      health_check_enabled             = true
      health_check_port                = var.port
      health_check_protocol            = "HTTP"
      health_check_path                = var.healthcheck_endpoint
      health_check_matcher             = "200-301"
      health_check_interval            = 30
      health_check_timeout             = 5
      health_check_threshold           = 2
      health_check_unhealthy_threshold = 2

      listener_443_arn    = local.listener_443_arn
      alb_arn_suffix      = local.alb_arn_suffix
      host_headers        = ["${var.app_name}.${local.root_domain}"]
      alarm_sns_topic_arn = local.sns_topic_arn
    }
  )
  green_target_group_config = merge(
    local.target_group_config,
    {
      tg_name  = "${var.app_name}-green"
      priority = var.priority + 1
    }
  )
}
