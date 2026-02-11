resource "aws_cloudwatch_log_group" "aurora" {
  for_each = toset(var.aurora_config.enabled_cloudwatch_logs_exports)

  name              = "/aws/rds/cluster/${local.cluster_identifier}/${each.value}"
  retention_in_days = var.aurora_config.log_retention_in_days
  kms_key_id        = aws_kms_key.aurora_cloudwatch.arn

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-${each.value}-logs"
  })
}
