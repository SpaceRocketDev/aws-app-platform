resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = format("%s-%s", var.alb_config.name_prefix, "microservices-alb-5xx")
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.alb_config.alb_5xx_threshold
  datapoints_to_alarm = "1"
  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
  }
  treat_missing_data = "notBreaching"
  alarm_actions      = [var.alb_config.alarm_sns_topic_arn]
}
resource "aws_cloudwatch_metric_alarm" "target_5xx" {
  alarm_name          = format("%s-%s", var.alb_config.name_prefix, "microservices-target-5xx")
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.alb_config.target_5xx_threshold
  datapoints_to_alarm = "1"
  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
  }
  treat_missing_data = "notBreaching"
  alarm_actions      = [var.alb_config.alarm_sns_topic_arn]
}