output "sns" {
  description = "All sns primitives as a single object for downstream stacks via remote state."
  value = {
    sns_topic_arn  = module.sns_dev_alerts.topic_arn
    sns_topic_name = module.sns_dev_alerts.topic_name
  }
}
