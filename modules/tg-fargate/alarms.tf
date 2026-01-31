# Alarm triggered when ALB target group reports unhealthy tasks
resource "aws_cloudwatch_metric_alarm" "unhealthy_instance_count" {
  alarm_name          = "${var.target_group_config.tg_name}-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_actions       = [var.target_group_config.alarm_sns_topic_arn]
  ok_actions          = [var.target_group_config.alarm_sns_topic_arn]
  dimensions = {
    LoadBalancer = var.target_group_config.alb_arn_suffix
    TargetGroup  = aws_lb_target_group.this[0].arn_suffix
  }
}
