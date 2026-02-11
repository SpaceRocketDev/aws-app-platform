# s3-replication.tf

############################################
# Artifact bucket replica
############################################
resource "aws_s3_bucket" "codepipeline_bucket_replica" {
  provider = aws.replica
  bucket   = "${local.task_name}-codepipeline-replica"
  tags     = local.common_tags
}

resource "aws_s3_bucket_ownership_controls" "codepipeline_bucket_replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.codepipeline_bucket_replica.id
  rule { object_ownership = "BucketOwnerEnforced" }
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_replica" {
  provider                = aws.replica
  bucket                  = aws_s3_bucket.codepipeline_bucket_replica.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_bucket_replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.codepipeline_bucket_replica.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.aws_kms_alias.s3kmskey_replica.target_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "codepipeline_bucket_replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.codepipeline_bucket_replica.id
  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled"
  }
  lifecycle { ignore_changes = [versioning_configuration[0].mfa_delete] }
}

############################################
# Access-logs bucket replica
############################################
resource "aws_s3_bucket" "codepipeline_access_logs_replica" {
  provider = aws.replica
  bucket   = "${local.task_name}-cp-access-replica"
  tags     = local.common_tags
}

resource "aws_s3_bucket_ownership_controls" "codepipeline_access_logs_replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.codepipeline_access_logs_replica.id
  rule { object_ownership = "BucketOwnerEnforced" }
}

resource "aws_s3_bucket_public_access_block" "codepipeline_access_logs_replica" {
  provider                = aws.replica
  bucket                  = aws_s3_bucket.codepipeline_access_logs_replica.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_access_logs_replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.codepipeline_access_logs_replica.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.aws_kms_alias.s3kmskey_replica.target_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "codepipeline_access_logs_replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.codepipeline_access_logs_replica.id
  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled"
  }
  lifecycle { ignore_changes = [versioning_configuration[0].mfa_delete] }
}

# Allow server access logs writer in replica region
data "aws_iam_policy_document" "codepipeline_access_logs_replica_policy" {
  statement {
    sid     = "S3ServerAccessLogsPolicyReplica"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    resources = ["${aws_s3_bucket.codepipeline_access_logs_replica.arn}/s3-access-logs/*"]
  }
}

resource "aws_s3_bucket_policy" "codepipeline_access_logs_replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.codepipeline_access_logs_replica.id
  policy   = data.aws_iam_policy_document.codepipeline_access_logs_replica_policy.json
}

############################################
# Secondary logs bucket in replica region (dst)
# KMS encrypted and replicated back to primary
############################################
resource "aws_s3_bucket" "codepipeline_access_logs_replica_dst" {
  provider = aws.replica
  bucket   = "${local.task_name}-cp-access-replica-dst"
  tags     = local.common_tags
}

resource "aws_s3_bucket_ownership_controls" "codepipeline_access_logs_replica_dst" {
  provider = aws.replica
  bucket   = aws_s3_bucket.codepipeline_access_logs_replica_dst.id
  rule { object_ownership = "BucketOwnerEnforced" }
}

resource "aws_s3_bucket_public_access_block" "codepipeline_access_logs_replica_dst" {
  provider                = aws.replica
  bucket                  = aws_s3_bucket.codepipeline_access_logs_replica_dst.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# KMS encryption to satisfy CKV_AWS_145
resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_access_logs_replica_dst" {
  provider = aws.replica
  bucket   = aws_s3_bucket.codepipeline_access_logs_replica_dst.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.aws_kms_alias.s3kmskey_replica.target_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "codepipeline_access_logs_replica_dst" {
  provider = aws.replica
  bucket   = aws_s3_bucket.codepipeline_access_logs_replica_dst.id
  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled"
  }
  lifecycle { ignore_changes = [versioning_configuration[0].mfa_delete] }
}

# Allow server access logs to write into the dst bucket
data "aws_iam_policy_document" "codepipeline_access_logs_replica_dst_policy" {
  statement {
    sid     = "S3ServerAccessLogsPolicyReplicaDst"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    resources = ["${aws_s3_bucket.codepipeline_access_logs_replica_dst.arn}/s3-access-logs-of-logs/*"]
  }
}

resource "aws_s3_bucket_policy" "codepipeline_access_logs_replica_dst" {
  provider = aws.replica
  bucket   = aws_s3_bucket.codepipeline_access_logs_replica_dst.id
  policy   = data.aws_iam_policy_document.codepipeline_access_logs_replica_dst_policy.json
}

############################################
# Enable server access logging in replica
############################################
# Artifact replica -> logs replica
resource "aws_s3_bucket_logging" "codepipeline_bucket_replica" {
  provider      = aws.replica
  bucket        = aws_s3_bucket.codepipeline_bucket_replica.id
  target_bucket = aws_s3_bucket.codepipeline_access_logs_replica.id
  target_prefix = "s3-access-logs/"
  depends_on = [
    aws_s3_bucket_policy.codepipeline_access_logs_replica,
    aws_s3_bucket_ownership_controls.codepipeline_access_logs_replica,
    aws_s3_bucket_public_access_block.codepipeline_access_logs_replica
  ]
}

# Logs replica -> dst bucket
resource "aws_s3_bucket_logging" "codepipeline_access_logs_replica" {
  provider      = aws.replica
  bucket        = aws_s3_bucket.codepipeline_access_logs_replica.id
  target_bucket = aws_s3_bucket.codepipeline_access_logs_replica_dst.id
  target_prefix = "s3-access-logs-of-logs/"
  depends_on = [
    aws_s3_bucket_policy.codepipeline_access_logs_replica_dst,
    aws_s3_bucket_ownership_controls.codepipeline_access_logs_replica_dst,
    aws_s3_bucket_public_access_block.codepipeline_access_logs_replica_dst
  ]
}

############################################
# Primary target for dst replication
############################################
resource "aws_s3_bucket" "codepipeline_access_logs_replica_dst_primary" {
  bucket = "${local.task_name}-cp-access-replica-dst-pri"
  tags   = local.common_tags
}

resource "aws_s3_bucket_ownership_controls" "codepipeline_access_logs_replica_dst_primary" {
  bucket = aws_s3_bucket.codepipeline_access_logs_replica_dst_primary.id
  rule { object_ownership = "BucketOwnerEnforced" }
}

resource "aws_s3_bucket_public_access_block" "codepipeline_access_logs_replica_dst_primary" {
  bucket                  = aws_s3_bucket.codepipeline_access_logs_replica_dst_primary.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_access_logs_replica_dst_primary" {
  bucket = aws_s3_bucket.codepipeline_access_logs_replica_dst_primary.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.aws_kms_alias.s3kmskey.target_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "codepipeline_access_logs_replica_dst_primary" {
  bucket = aws_s3_bucket.codepipeline_access_logs_replica_dst_primary.id
  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled"
  }
  lifecycle { ignore_changes = [versioning_configuration[0].mfa_delete] }
}

############################################
# Replication role and policy
############################################
data "aws_iam_policy_document" "replication_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "replication" {
  name               = "${local.task_name}-s3-replication-role"
  assume_role_policy = data.aws_iam_policy_document.replication_assume.json
}

data "aws_iam_policy_document" "replication_policy" {
  # Read source: artifact bucket
  statement {
    effect    = "Allow"
    actions   = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
    resources = [aws_s3_bucket.codepipeline_bucket.arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectLegalHold",
      "s3:GetObjectVersionTagging",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]
    resources = ["${aws_s3_bucket.codepipeline_bucket.arn}/*"]
  }

  # Read source: access-logs bucket
  statement {
    effect    = "Allow"
    actions   = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
    resources = [aws_s3_bucket.codepipeline_access_logs.arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectLegalHold",
      "s3:GetObjectVersionTagging",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]
    resources = ["${aws_s3_bucket.codepipeline_access_logs.arn}/*"]
  }

  # Read source: replica dst bucket
  statement {
    effect    = "Allow"
    actions   = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
    resources = [aws_s3_bucket.codepipeline_access_logs_replica_dst.arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectLegalHold",
      "s3:GetObjectVersionTagging",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]
    resources = ["${aws_s3_bucket.codepipeline_access_logs_replica_dst.arn}/*"]
  }

  # Write destination: artifact bucket replica
  statement {
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]
    resources = ["${aws_s3_bucket.codepipeline_bucket_replica.arn}/*"]
  }

  # Write destination: access-logs bucket replica
  statement {
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]
    resources = ["${aws_s3_bucket.codepipeline_access_logs_replica.arn}/*"]
  }

  # Write destination: dst primary bucket
  statement {
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]
    resources = ["${aws_s3_bucket.codepipeline_access_logs_replica_dst_primary.arn}/*"]
  }

  # KMS on sources
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:DescribeKey"]
    resources = [data.aws_kms_alias.s3kmskey.target_key_arn, data.aws_kms_alias.s3kmskey_replica.target_key_arn]
  }

  # KMS on destinations
  statement {
    effect    = "Allow"
    actions   = ["kms:Encrypt", "kms:ReEncrypt*", "kms:DescribeKey", "kms:GenerateDataKey*"]
    resources = [data.aws_kms_alias.s3kmskey.target_key_arn, data.aws_kms_alias.s3kmskey_replica.target_key_arn]
  }
}

resource "aws_iam_role_policy" "replication" {
  role   = aws_iam_role.replication.id
  policy = data.aws_iam_policy_document.replication_policy.json
}

############################################
# Replication configurations
############################################
resource "aws_s3_bucket_replication_configuration" "codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "replicate-all"
    status = "Enabled"

    delete_marker_replication { status = "Enabled" }
    filter { prefix = "" }

    source_selection_criteria {
      sse_kms_encrypted_objects { status = "Enabled" }
    }

    destination {
      bucket        = aws_s3_bucket.codepipeline_bucket_replica.arn
      storage_class = "STANDARD"

      encryption_configuration {
        replica_kms_key_id = data.aws_kms_alias.s3kmskey_replica.target_key_arn
      }
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.codepipeline_bucket,
    aws_s3_bucket_versioning.codepipeline_bucket_replica,
    aws_s3_bucket_public_access_block.codepipeline_bucket,
    aws_s3_bucket_public_access_block.codepipeline_bucket_replica
  ]
}

resource "aws_s3_bucket_replication_configuration" "codepipeline_access_logs" {
  bucket = aws_s3_bucket.codepipeline_access_logs.id
  role   = aws_iam_role.replication.arn

  rule {
    id     = "replicate-access-logs"
    status = "Enabled"

    delete_marker_replication { status = "Enabled" }
    filter { prefix = "" }

    source_selection_criteria {
      sse_kms_encrypted_objects { status = "Enabled" }
    }

    destination {
      bucket        = aws_s3_bucket.codepipeline_access_logs_replica.arn
      storage_class = "STANDARD"

      encryption_configuration {
        replica_kms_key_id = data.aws_kms_alias.s3kmskey_replica.target_key_arn
      }
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.codepipeline_access_logs,
    aws_s3_bucket_versioning.codepipeline_access_logs_replica,
    aws_s3_bucket_public_access_block.codepipeline_access_logs,
    aws_s3_bucket_public_access_block.codepipeline_access_logs_replica
  ]
}

# New: replicate the dst bucket back to primary to satisfy CKV_AWS_144
resource "aws_s3_bucket_replication_configuration" "codepipeline_access_logs_replica_dst" {
  provider = aws.replica
  bucket   = aws_s3_bucket.codepipeline_access_logs_replica_dst.id
  role     = aws_iam_role.replication.arn

  rule {
    id     = "replicate-dst-to-primary"
    status = "Enabled"

    delete_marker_replication { status = "Enabled" }
    filter { prefix = "" }

    source_selection_criteria {
      sse_kms_encrypted_objects { status = "Enabled" }
    }

    destination {
      bucket        = aws_s3_bucket.codepipeline_access_logs_replica_dst_primary.arn
      storage_class = "STANDARD"

      encryption_configuration {
        replica_kms_key_id = data.aws_kms_alias.s3kmskey.target_key_arn
      }
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.codepipeline_access_logs_replica_dst,
    aws_s3_bucket_versioning.codepipeline_access_logs_replica_dst_primary,
    aws_s3_bucket_public_access_block.codepipeline_access_logs_replica_dst,
    aws_s3_bucket_public_access_block.codepipeline_access_logs_replica_dst_primary
  ]
}

# Enable server access logging on the primary dst bucket
resource "aws_s3_bucket_logging" "codepipeline_access_logs_replica_dst_primary" {
  bucket        = aws_s3_bucket.codepipeline_access_logs_replica_dst_primary.id
  target_bucket = aws_s3_bucket.codepipeline_access_logs.id
  target_prefix = "s3-access-logs/"

  depends_on = [
    aws_s3_bucket_policy.codepipeline_access_logs,
    aws_s3_bucket_ownership_controls.codepipeline_access_logs,
    aws_s3_bucket_public_access_block.codepipeline_access_logs
  ]
}

# Lifecycle for artifact bucket replica
resource "aws_s3_bucket_lifecycle_configuration" "codepipeline_bucket_replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.codepipeline_bucket_replica.id

  rule {
    id     = "expire-artifacts"
    status = "Enabled"

    abort_incomplete_multipart_upload { days_after_initiation = 7 }
    expiration { days = 90 }
  }
}

# Lifecycle for access-logs bucket replica
resource "aws_s3_bucket_lifecycle_configuration" "codepipeline_access_logs_replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.codepipeline_access_logs_replica.id

  rule {
    id     = "expire-access-logs"
    status = "Enabled"

    abort_incomplete_multipart_upload { days_after_initiation = 7 }
    expiration { days = 365 }
  }
}

# Lifecycle for dst logs bucket in replica region
resource "aws_s3_bucket_lifecycle_configuration" "codepipeline_access_logs_replica_dst" {
  provider = aws.replica
  bucket   = aws_s3_bucket.codepipeline_access_logs_replica_dst.id

  rule {
    id     = "expire-access-logs-of-logs"
    status = "Enabled"

    abort_incomplete_multipart_upload { days_after_initiation = 7 }
    expiration { days = 365 }
  }
}

# Lifecycle for primary bucket that receives dst replication
resource "aws_s3_bucket_lifecycle_configuration" "codepipeline_access_logs_replica_dst_primary" {
  bucket = aws_s3_bucket.codepipeline_access_logs_replica_dst_primary.id

  rule {
    id     = "expire-access-logs-pri"
    status = "Enabled"

    abort_incomplete_multipart_upload { days_after_initiation = 7 }
    expiration { days = 365 }
  }
}

# Event notifications for the artifact replica bucket
resource "aws_s3_bucket_notification" "codepipeline_bucket_replica_eventbridge" {
  provider    = aws.replica
  bucket      = aws_s3_bucket.codepipeline_bucket_replica.id
  eventbridge = true
  depends_on = [
    aws_s3_bucket_ownership_controls.codepipeline_bucket_replica,
    aws_s3_bucket_public_access_block.codepipeline_bucket_replica
  ]
}

# Event notifications for the access-logs replica bucket
resource "aws_s3_bucket_notification" "codepipeline_access_logs_replica_eventbridge" {
  provider    = aws.replica
  bucket      = aws_s3_bucket.codepipeline_access_logs_replica.id
  eventbridge = true
  depends_on = [
    aws_s3_bucket_ownership_controls.codepipeline_access_logs_replica,
    aws_s3_bucket_public_access_block.codepipeline_access_logs_replica
  ]
}

# Event notifications for the dst logs bucket in replica region
resource "aws_s3_bucket_notification" "codepipeline_access_logs_replica_dst_eventbridge" {
  provider    = aws.replica
  bucket      = aws_s3_bucket.codepipeline_access_logs_replica_dst.id
  eventbridge = true
  depends_on = [
    aws_s3_bucket_ownership_controls.codepipeline_access_logs_replica_dst,
    aws_s3_bucket_public_access_block.codepipeline_access_logs_replica_dst
  ]
}

# Event notifications for the primary bucket that receives dst replication
resource "aws_s3_bucket_notification" "codepipeline_access_logs_replica_dst_primary_eventbridge" {
  bucket      = aws_s3_bucket.codepipeline_access_logs_replica_dst_primary.id
  eventbridge = true
  depends_on = [
    aws_s3_bucket_ownership_controls.codepipeline_access_logs_replica_dst_primary,
    aws_s3_bucket_public_access_block.codepipeline_access_logs_replica_dst_primary
  ]
}

