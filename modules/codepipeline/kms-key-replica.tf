data "aws_region" "replica" {
  provider = aws.replica
}

resource "aws_kms_key" "s3kmskey_replica" {
  provider                = aws.replica
  description             = "KMS key for S3 replica bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableRootPermissionsReplica"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${local.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowS3UseForReplicaBuckets"
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = ["kms:Encrypt","kms:Decrypt","kms:ReEncrypt*","kms:GenerateDataKey*","kms:CreateGrant","kms:DescribeKey"]
        Resource  = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
            "kms:ViaService"    = "s3.${data.aws_region.replica.id}.amazonaws.com"
          },
          ArnLike = {
            "kms:EncryptionContext:aws:s3:arn" = [
              "arn:aws:s3:::${aws_s3_bucket.codepipeline_bucket_replica.id}/*",
              "arn:aws:s3:::${aws_s3_bucket.codepipeline_access_logs_replica.id}/*",
              "arn:aws:s3:::${aws_s3_bucket.codepipeline_access_logs_replica_dst.id}/*"
            ]
          }
        }
      },
      {
        Sid       = "AllowReplicationRoleUseOnDest"
        Effect    = "Allow"
        Principal = { AWS = "${aws_iam_role.replication.arn}" }
        Action    = ["kms:Encrypt","kms:ReEncrypt*","kms:GenerateDataKey*","kms:DescribeKey"]
        Resource  = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "s3kmskey_replica" {
  provider      = aws.replica
  name          = "alias/${local.task_name}-kms-key-replica"
  target_key_id = aws_kms_key.s3kmskey_replica.id
}

data "aws_kms_alias" "s3kmskey_replica" {
  provider = aws.replica
  name     = aws_kms_alias.s3kmskey_replica.name
}
