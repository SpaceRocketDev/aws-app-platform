output "topic_arn" {
  description = "The ARN of the SNS topic, as a more obvious property (clone of id)"
  value = aws_sns_topic.this.arn
}

output "topic_name" {
  description = "(Optional) The name of the topic. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 256 characters long. For a FIFO (first-in-first-out) topic, the name must end with the .fifo suffix. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix"
  value = aws_sns_topic.this.name
}
