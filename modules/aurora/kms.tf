resource "aws_kms_key" "aurora" {
  description             = "KMS key for Aurora PostgreSQL storage encryption"
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
        Sid       = "AllowRDSServiceToUseKey"
        Effect    = "Allow"
        Principal = { Service = "rds.amazonaws.com" }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:CreateGrant",
          "kms:ReEncrypt*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.aurora_config.account_id
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-kms"
  })
}

resource "aws_kms_alias" "aurora" {
  name          = "alias/${local.name_prefix}-aurora"
  target_key_id = aws_kms_key.aurora.key_id
}
