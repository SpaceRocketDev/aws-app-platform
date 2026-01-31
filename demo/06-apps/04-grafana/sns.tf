# Customer managed KMS key used to encrypt the SNS topic
resource "aws_kms_key" "sns_topic" {
  description             = "Customer managed KMS key used to encrypt the SNS topic"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  # Key policy allows account root and SNS service to use the key
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid : "EnableRootPermissions",
        Effect : "Allow",
        Principal : { AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
        Action : "kms:*",
        Resource : "*"
      },
      {
        Sid : "AllowSNSToUseKeyForThisTopic",
        Effect : "Allow",
        Principal : { Service : "sns.amazonaws.com" },
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        Resource : "*",
        Condition : {
          StringEquals : {
            "aws:SourceAccount" : "${data.aws_caller_identity.current.account_id}"
          },
          ArnLike : {
            "kms:EncryptionContext:aws:sns:arn" : "arn:aws:sns:${local.region}:${data.aws_caller_identity.current.account_id}:${local.task_name}-codepipeline-notify"
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.task_name}-sns-kms"
  })
}

# Alias for the SNS KMS key
resource "aws_kms_alias" "sns_topic" {
  name          = "alias/${local.task_name}-sns"
  target_key_id = aws_kms_key.sns_topic.key_id
}

# SNS topic used for CodePipeline and deployment notifications
resource "aws_sns_topic" "codepipeline_notifications" {
  name              = "${local.task_name}-codepipeline-notify"
  kms_master_key_id = aws_kms_key.sns_topic.arn
  tags              = local.common_tags
}

# Allows CodeStar Notifications to publish to the application SNS topic
data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]
    principals {
      type        = "Service"
      identifiers = ["codestar.amazonaws.com"]
    }
    resources = [aws_sns_topic.codepipeline_notifications.arn]
  }
}

# Allows CodeStar Notifications to publish to the application SNS topic
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.codepipeline_notifications.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}
