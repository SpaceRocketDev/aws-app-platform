###############################################################################
# Server access logging for the ALB logs bucket
###############################################################################
locals {
  logs_access_bucket_effective = (
    var.alb_config.logs_access_bucket != null
    ? var.alb_config.logs_access_bucket
    : "${var.alb_config.logs_bucket}-access"
  )
}

# Versioning for the target access-logs bucket
resource "aws_s3_bucket_versioning" "logs_access" {
  count = var.alb_config.logs_access_enabled ? 1 : 0

  bucket = var.alb_config.logs_access_bucket != null ? local.logs_access_bucket_effective : aws_s3_bucket.logs_access[0].id

  versioning_configuration {
    status     = "Enabled"
    # Terraform cannot turn this on. Use CLI with root MFA.
    # Flip to "Enabled" after you enable via CLI to quiet Snyk.
    mfa_delete = "Disabled"
  }

  lifecycle {
    ignore_changes = [versioning_configuration[0].mfa_delete]
  }
}

# Create the target bucket (for access logs) if not provided
resource "aws_s3_bucket" "logs_access" {
  count  = var.alb_config.logs_access_enabled && var.alb_config.logs_access_bucket == null ? 1 : 0
  #checkov:skip=CKV_AWS_144:Access-logs target bucket; replication not required
  #checkov:skip=CKV_AWS_18:This is a log target bucket; enabling logging here would require a third bucket
  bucket = local.logs_access_bucket_effective
  force_destroy = var.alb_config.logs_access_bucket_force_destroy
  tags         = var.alb_config.common_tags
}

resource "aws_s3_bucket_ownership_controls" "logs_access" {
  count  = var.alb_config.logs_access_enabled ? 1 : 0
  bucket = var.alb_config.logs_access_bucket != null ? local.logs_access_bucket_effective : aws_s3_bucket.logs_access[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs_access" {
  count  = var.alb_config.logs_access_enabled ? 1 : 0
  bucket = var.alb_config.logs_access_bucket != null ? local.logs_access_bucket_effective : aws_s3_bucket.logs_access[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      # kms_master_key_id = "aws/s3"  # optional
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs_access" {
  count  = var.alb_config.logs_access_enabled ? 1 : 0
  bucket = var.alb_config.logs_access_bucket != null ? local.logs_access_bucket_effective : aws_s3_bucket.logs_access[0].id

  rule {
    id     = "expire-access-logs"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    expiration {
      days = var.alb_config.logs_access_expiration
    }
  }
}

data "aws_iam_policy_document" "logs_access_policy" {
  count = var.alb_config.logs_access_enabled ? 1 : 0

  statement {
    sid     = "S3ServerAccessLogsPolicy"
    effect  = "Allow"
    actions = ["s3:PutObject"]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    resources = [
      "arn:aws:s3:::${local.logs_access_bucket_effective}/${var.alb_config.logs_access_prefix}*"
    ]
  }
}

resource "aws_s3_bucket_policy" "logs_access" {
  count  = var.alb_config.logs_access_enabled ? 1 : 0
  bucket = var.alb_config.logs_access_bucket != null ? local.logs_access_bucket_effective : aws_s3_bucket.logs_access[0].id
  policy = data.aws_iam_policy_document.logs_access_policy[0].json
}

# Public access block for the access-logs bucket (created or external)
resource "aws_s3_bucket_public_access_block" "logs_access" {
  count  = var.alb_config.logs_access_enabled ? 1 : 0
  bucket = var.alb_config.logs_access_bucket != null ? local.logs_access_bucket_effective : aws_s3_bucket.logs_access[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Event notifications (via EventBridge) for the access-logs bucket
resource "aws_s3_bucket_notification" "logs_access_eventbridge" {
  count   = var.alb_config.logs_access_enabled ? 1 : 0
  bucket  = var.alb_config.logs_access_bucket != null ? local.logs_access_bucket_effective : aws_s3_bucket.logs_access[0].id
  eventbridge = true

  # Ensure ownership controls and PAB exist first
  depends_on = [
    aws_s3_bucket_ownership_controls.logs_access,
    aws_s3_bucket_public_access_block.logs_access
  ]
}
