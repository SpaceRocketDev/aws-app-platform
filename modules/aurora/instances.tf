resource "aws_rds_cluster_instance" "aurora" {
  count = var.aurora_config.instance_count

  identifier         = "${local.cluster_identifier}-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.aurora_config.instance_class
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  db_parameter_group_name = aws_db_parameter_group.aurora.name

  # Performance Insights
  performance_insights_enabled    = var.aurora_config.performance_insights_enabled
  performance_insights_kms_key_id = var.aurora_config.performance_insights_enabled ? aws_kms_key.aurora.arn : null

  # Maintenance
  preferred_maintenance_window = var.aurora_config.preferred_maintenance_window
  copy_tags_to_snapshot        = true

  tags = merge(local.common_tags, {
    Name = "${local.cluster_identifier}-${count.index}"
  })
}
