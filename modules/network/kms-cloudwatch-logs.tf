locals {
  kms_region  = var.network_config.aws_region
  kms_account = var.network_config.account_id != "" ? var.network_config.account_id : data.aws_caller_identity.current.account_id
}

# KMS CMK for encrypting CloudWatch Logs (used by VPC Flow Logs log group)
resource "aws_kms_key" "cloudwatch_logs" {
  description         = "KMS CMK for CloudWatch Logs encryption"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "EnableRootPermissions",
        Effect = "Allow",
        Principal = { 
          AWS = "arn:aws:iam::${local.kms_account}:root" 
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogsUse",
        Effect = "Allow",
        Principal = { 
          Service = "logs.${local.kms_region}.amazonaws.com" 
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ],
        Resource = "*",
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${local.kms_region}:${local.kms_account}:log-group:/aws/vpc/flow-logs/${var.network_config.name_prefix}"
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-cloudwatch-logs-kms" })
}

# Friendly alias for the CloudWatch Logs KMS key
resource "aws_kms_alias" "cloudwatch_logs" {
  name          = "alias/${local.name_prefix}-cloudwatch-logs"
  target_key_id = aws_kms_key.cloudwatch_logs.key_id
}