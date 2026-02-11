# AWS WAF v2 Web ACL for ALB protection
# CIS AWS Foundations Benchmark: CKV2_AWS_28, CKV2_AWS_31, CKV2_AWS_76
# Protects public-facing ALB against OWASP Top 10 attacks

resource "aws_wafv2_web_acl" "this" {
  count = var.alb_config.enable_waf ? 1 : 0

  name        = "${local.name_prefix}-waf"
  description = "WAF Web ACL for ${local.name_prefix} ALB"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # AWS Managed Rules - Common Rule Set
  # Covers OWASP Top 10 including XSS, SQLi, path traversal, and more
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-common-rules"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - Known Bad Inputs (Log4j/Log4Shell, Java deserialization)
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-known-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-waf"
    sampled_requests_enabled   = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-waf"
  })
}

resource "aws_wafv2_web_acl_association" "this" {
  count = var.alb_config.enable_waf ? 1 : 0

  resource_arn = aws_lb.this.arn
  web_acl_arn  = aws_wafv2_web_acl.this[0].arn
}

# KMS key for WAF CloudWatch Logs encryption — CKV_AWS_158
resource "aws_kms_key" "waf_logs" {
  count = var.alb_config.enable_waf ? 1 : 0

  description             = "KMS key for WAF CloudWatch Logs encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableIAMUserPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${var.alb_config.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowCloudWatchLogs"
        Effect    = "Allow"
        Principal = { Service = "logs.${var.alb_config.aws_region}.amazonaws.com" }
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
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.alb_config.aws_region}:${var.alb_config.account_id}:log-group:aws-waf-logs-${local.name_prefix}"
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-waf-logs-kms"
  })
}

resource "aws_kms_alias" "waf_logs" {
  count = var.alb_config.enable_waf ? 1 : 0

  name          = "alias/${local.name_prefix}-waf-logs"
  target_key_id = aws_kms_key.waf_logs[0].key_id
}

# WAF Logging — CKV2_AWS_31
# CloudWatch Log Group must use the "aws-waf-logs-" prefix (AWS requirement)
resource "aws_cloudwatch_log_group" "waf" {
  count = var.alb_config.enable_waf ? 1 : 0

  name              = "aws-waf-logs-${local.name_prefix}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.waf_logs[0].arn

  tags = merge(local.common_tags, {
    Name = "aws-waf-logs-${local.name_prefix}"
  })
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = var.alb_config.enable_waf ? 1 : 0

  log_destination_configs = [aws_cloudwatch_log_group.waf[0].arn]
  resource_arn            = aws_wafv2_web_acl.this[0].arn
}
