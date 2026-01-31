resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${local.task_name}-codepipeline"
}

# Server access logging target for the artifact bucket
resource "aws_s3_bucket" "codepipeline_access_logs" {
  bucket        = "${local.task_name}-codepipeline-access"
  force_destroy = false
  tags          = local.common_tags
}

resource "aws_s3_bucket_ownership_controls" "codepipeline_access_logs" {
  bucket = aws_s3_bucket.codepipeline_access_logs.id
  rule { object_ownership = "BucketOwnerEnforced" }
}

resource "aws_s3_bucket_public_access_block" "codepipeline_access_logs" {
  bucket                  = aws_s3_bucket.codepipeline_access_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CKV_AWS_145 fix: use KMS for access logs bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_access_logs" {
  bucket = aws_s3_bucket.codepipeline_access_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.aws_kms_alias.s3kmskey.target_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "codepipeline_access_logs" {
  bucket = aws_s3_bucket.codepipeline_access_logs.id
  rule {
    id     = "expire-access-logs"
    status = "Enabled"
    abort_incomplete_multipart_upload { days_after_initiation = 7 }
    expiration { days = 365 }
  }
}

# Allow S3 server access logs to write into target bucket
data "aws_iam_policy_document" "codepipeline_access_logs_policy" {
  statement {
    sid     = "S3ServerAccessLogsPolicy"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    resources = ["${aws_s3_bucket.codepipeline_access_logs.arn}/s3-access-logs/*"]
  }
}

resource "aws_s3_bucket_policy" "codepipeline_access_logs" {
  bucket = aws_s3_bucket.codepipeline_access_logs.id
  policy = data.aws_iam_policy_document.codepipeline_access_logs_policy.json
}

# Ownership + PAB for artifact bucket
resource "aws_s3_bucket_ownership_controls" "codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  rule { object_ownership = "BucketOwnerEnforced" }
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket" {
  bucket                  = aws_s3_bucket.codepipeline_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# KMS-SSE with your key
resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.aws_kms_alias.s3kmskey.target_key_arn
    }
    bucket_key_enabled = true
  }
}

# Versioning
resource "aws_s3_bucket_versioning" "codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled"
  }
  lifecycle { ignore_changes = [versioning_configuration[0].mfa_delete] }
}

# Lifecycle
resource "aws_s3_bucket_lifecycle_configuration" "codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  rule {
    id     = "expire-artifacts"
    status = "Enabled"
    abort_incomplete_multipart_upload { days_after_initiation = 7 }
    expiration { days = 90 }
  }
}

# Access logging
resource "aws_s3_bucket_logging" "codepipeline_bucket" {
  bucket        = aws_s3_bucket.codepipeline_bucket.id
  target_bucket = aws_s3_bucket.codepipeline_access_logs.id
  target_prefix = "s3-access-logs/"
  depends_on = [
    aws_s3_bucket_policy.codepipeline_access_logs,
    aws_s3_bucket_ownership_controls.codepipeline_access_logs,
    aws_s3_bucket_public_access_block.codepipeline_access_logs
  ]
}

# Event notifications via EventBridge
resource "aws_s3_bucket_notification" "codepipeline_bucket_eventbridge" {
  bucket      = aws_s3_bucket.codepipeline_bucket.id
  eventbridge = true
  depends_on = [
    aws_s3_bucket_ownership_controls.codepipeline_bucket,
    aws_s3_bucket_public_access_block.codepipeline_bucket
  ]
}

# Versioning for access-logs bucket (CKV_AWS_21)
resource "aws_s3_bucket_versioning" "codepipeline_access_logs" {
  bucket = aws_s3_bucket.codepipeline_access_logs.id
  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled"
  }
  # AWS sets MFA Delete by hand only; ignore drift
  lifecycle { ignore_changes = [versioning_configuration[0].mfa_delete] }
}

# Event notifications via EventBridge for the access-logs bucket
resource "aws_s3_bucket_notification" "codepipeline_access_logs_eventbridge" {
  bucket      = aws_s3_bucket.codepipeline_access_logs.id
  eventbridge = true
  depends_on = [
    aws_s3_bucket_ownership_controls.codepipeline_access_logs,
    aws_s3_bucket_public_access_block.codepipeline_access_logs
  ]
}

