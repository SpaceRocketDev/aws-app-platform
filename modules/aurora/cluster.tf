resource "aws_rds_cluster" "aurora" {
  cluster_identifier = local.cluster_identifier
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version     = var.aurora_config.engine_version
  database_name      = local.database_name

  # Managed master credentials via Secrets Manager
  master_username                 = "postgres"
  manage_master_user_password     = true
  iam_database_authentication_enabled = true

  # Serverless v2 scaling
  serverlessv2_scaling_configuration {
    min_capacity = var.aurora_config.min_acu
    max_capacity = var.aurora_config.max_acu
  }

  # Networking
  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.aurora.id]

  # Encryption
  storage_encrypted = true
  kms_key_id        = aws_kms_key.aurora.arn

  # Backups
  backup_retention_period      = var.aurora_config.backup_retention_period
  preferred_backup_window      = var.aurora_config.preferred_backup_window
  preferred_maintenance_window = var.aurora_config.preferred_maintenance_window
  copy_tags_to_snapshot        = true

  # Protection
  deletion_protection = var.aurora_config.deletion_protection
  skip_final_snapshot = var.aurora_config.skip_final_snapshot
  final_snapshot_identifier = var.aurora_config.skip_final_snapshot ? null : "${local.cluster_identifier}-final"

  # Parameter group
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name

  # CloudWatch Logs exports
  enabled_cloudwatch_logs_exports = var.aurora_config.enabled_cloudwatch_logs_exports

  tags = merge(local.common_tags, {
    Name = local.cluster_identifier
  })

  depends_on = [aws_cloudwatch_log_group.aurora]
}
