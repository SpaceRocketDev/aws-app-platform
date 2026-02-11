resource "aws_rds_cluster_parameter_group" "aurora" {
  name        = "${local.name_prefix}-aurora-pg-cluster"
  family      = "aurora-postgresql16"
  description = "Aurora PostgreSQL cluster parameter group"

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "log_statement"
    value = "ddl"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-pg-cluster"
  })
}

resource "aws_db_parameter_group" "aurora" {
  name        = "${local.name_prefix}-aurora-pg-instance"
  family      = "aurora-postgresql16"
  description = "Aurora PostgreSQL instance parameter group"

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "pg_stat_statements.track"
    value = "all"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-pg-instance"
  })
}
