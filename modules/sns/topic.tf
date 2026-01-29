# modules/sns/topic.tf
resource "aws_sns_topic" "this" {
  name            = var.sns_config.topic_name
  display_name    = var.sns_config.topic_name

  delivery_policy = jsonencode({
    http = {
      defaultHealthyRetryPolicy = {
        minDelayTarget     = 20
        maxDelayTarget     = 20
        numRetries         = 3
        numMaxDelayRetries = 0
        numNoDelayRetries  = 0
        numMinDelayRetries = 0
        backoffFunction    = "linear"
      }
      disableSubscriptionOverrides = false
    }
  })

  kms_master_key_id = coalesce(var.sns_config.kms_key_arn, "alias/aws/sns")

  tags = local.common_tags
}
