resource "aws_kms_key" "alb_logs" {
  description             = "KMS key for ALB access logs encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableIAMUserPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${var.alb_config.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowELBServiceToUseKey"
        Effect    = "Allow"
        Principal = { Service = "logdelivery.elasticloadbalancing.amazonaws.com" }
        Action    = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource  = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.alb_config.account_id
          }
        }
      },
      {
        Sid       = "AllowELBRegionalAccountToUseKey"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${local.lb_account_id}:root" }
        Action    = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      },
      {
        Sid: "AllowS3ToUseKeyForLogsBucket",
        Effect: "Allow",
        Principal: { Service: "s3.amazonaws.com" },
        Action: [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ],
        Resource: "*",
        Condition: {
          StringEquals: {
            "aws:SourceAccount": "${var.alb_config.account_id}",
            "kms:ViaService": "s3.${var.alb_config.aws_region}.amazonaws.com"
          },
          ArnLike: {
            "kms:EncryptionContext:aws:s3:arn": "arn:aws:s3:::${var.alb_config.logs_bucket}/*"
          }
        }
      }
     
    ]
  })

  tags = merge(var.alb_config.common_tags, {
    Name = "${var.alb_config.name_prefix}-alb-logs-kms"
  })
}

resource "aws_kms_alias" "alb_logs" {
  name          = "alias/${var.alb_config.name_prefix}-alb-logs"
  target_key_id = aws_kms_key.alb_logs.key_id
}