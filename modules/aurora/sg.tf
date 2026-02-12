resource "aws_security_group" "aurora" {
  description = "Aurora PostgreSQL ${upper(var.aurora_config.env)}"
  name        = "${local.name_prefix}-aurora-pg"
  vpc_id      = var.aurora_config.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-pg"
  })
}

# Ingress: allow 5432 from each specified security group
resource "aws_security_group_rule" "aurora_ingress" {
  count = length(var.aurora_config.allowed_security_group_ids)

  description              = "PostgreSQL from allowed SG"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.aurora_config.allowed_security_group_ids[count.index]
  security_group_id        = aws_security_group.aurora.id
}

# Egress: allow all outbound
resource "aws_security_group_rule" "aurora_egress" {
  description       = "Aurora ${upper(var.aurora_config.env)} Egress"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aurora.id
}
