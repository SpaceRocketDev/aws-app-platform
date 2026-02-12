output "cluster_identifier" {
  description = "The Aurora cluster identifier"
  value       = aws_rds_cluster.aurora.cluster_identifier
}

output "cluster_endpoint" {
  description = "Writer endpoint for the Aurora cluster"
  value       = aws_rds_cluster.aurora.endpoint
}

output "cluster_reader_endpoint" {
  description = "Reader endpoint for the Aurora cluster"
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "cluster_port" {
  description = "Port the Aurora cluster listens on"
  value       = aws_rds_cluster.aurora.port
}

output "cluster_arn" {
  description = "ARN of the Aurora cluster"
  value       = aws_rds_cluster.aurora.arn
}

output "database_name" {
  description = "Name of the default database"
  value       = aws_rds_cluster.aurora.database_name
}

output "security_group_id" {
  description = "Security group ID attached to the Aurora cluster"
  value       = aws_security_group.aurora.id
}

output "master_secret_arn" {
  description = "ARN of the Secrets Manager secret containing master credentials"
  value       = aws_rds_cluster.aurora.master_user_secret[0].secret_arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for storage encryption"
  value       = aws_kms_key.aurora.arn
}

output "aurora" {
  description = "Aurora primitives for downstream stacks via remote state (stable contract)."
  value = {
    cluster_identifier      = aws_rds_cluster.aurora.cluster_identifier
    cluster_endpoint        = aws_rds_cluster.aurora.endpoint
    cluster_reader_endpoint = aws_rds_cluster.aurora.reader_endpoint
    cluster_port            = aws_rds_cluster.aurora.port
    cluster_arn             = aws_rds_cluster.aurora.arn
    database_name           = aws_rds_cluster.aurora.database_name
    security_group_id       = aws_security_group.aurora.id
    master_secret_arn       = aws_rds_cluster.aurora.master_user_secret[0].secret_arn
    kms_key_arn             = aws_kms_key.aurora.arn
  }
}
