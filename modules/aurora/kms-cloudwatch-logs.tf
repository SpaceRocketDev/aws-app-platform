resource "aws_kms_key" "aurora_cloudwatch" {
  description             = "KMS key for Aurora PostgreSQL CloudWatch Logs encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableIAMUserPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${var.aurora_config.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowCloudWatchLogsToUseKey"
        Effect    = "Allow"
        Principal = { Service = "logs.${var.aurora_config.aws_region}.amazonaws.com" }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.aurora_config.aws_region}:${var.aurora_config.account_id}:log-group:/aws/rds/cluster/${local.cluster_identifier}/*"
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-cloudwatch-kms"
  })
}

resource "aws_kms_alias" "aurora_cloudwatch" {
  name          = "alias/${local.name_prefix}-aurora-cloudwatch"
  target_key_id = aws_kms_key.aurora_cloudwatch.key_id
}
