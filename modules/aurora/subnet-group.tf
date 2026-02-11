resource "aws_db_subnet_group" "aurora" {
  name       = "${local.name_prefix}-aurora-pg"
  subnet_ids = var.aurora_config.private_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-pg"
  })
}
