#######################
# CloudWatch Log Group (KMS-encrypted)
#######################
# KMS key used to encrypt CloudWatch Logs
resource "aws_kms_key" "cloudwatch_logs" {
  description             = "KMS key used to encrypt CloudWatch Logs"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowRootAccountAdministration",
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::${var.ecs_service_config.account_id}:root" },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "AllowCloudWatchLogsUseOfTheKey",
      "Effect": "Allow",
      "Principal": { "Service": "logs.${var.ecs_service_config.region}.amazonaws.com" },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*",
      "Condition": {
        "ArnLike": {
          "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${var.ecs_service_config.region}:${var.ecs_service_config.account_id}:log-group:${var.ecs_service_config.log_group_name}*"
        }
      }
    }
  ]
}
POLICY
}

# Alias for the CloudWatch Logs KMS key
resource "aws_kms_alias" "cloudwatch_logs" {
  name          = "alias/${var.ecs_service_config.app_name}-cloudwatch-logs"
  target_key_id = aws_kms_key.cloudwatch_logs.key_id
}

# KMS encrypted CloudWatch log group for application logs
resource "aws_cloudwatch_log_group" "fargate_task_log_group" {
  name              = var.ecs_service_config.log_group_name
  retention_in_days = 365
  kms_key_id        = aws_kms_key.cloudwatch_logs.arn

  tags = try(var.ecs_service_config.common_tags, null)
}

# Optional: dedicated stream (not required for CKV_AWS_158)
# resource "aws_cloudwatch_log_stream" "fargate_task_log_stream" {
#   name           = var.ecs_service_config.task_name
#   log_group_name = aws_cloudwatch_log_group.fargate_task_log_group.name
# }
