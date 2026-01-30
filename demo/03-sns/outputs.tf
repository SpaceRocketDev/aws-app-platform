output "sns_topic_arn" {
  description = "Primary SNS topic ARN."
  value       = module.sns_dev_alerts.topic_arn
}

output "sns_topic_name" {
  description = "Primary SNS topic name."
  value       = module.sns_dev_alerts.topic_name
}
