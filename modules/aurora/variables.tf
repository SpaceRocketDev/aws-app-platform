variable "aurora_config" {
  description = "Composite config for Aurora PostgreSQL cluster, instances, networking, encryption, and tags."

  type = object({
    account_id  = string
    env         = string
    project     = string
    name_prefix = string
    aws_region  = string

    engine_version = optional(string, "16.4")
    database_name  = string

    min_acu        = optional(number, 0.5)
    max_acu        = optional(number, 2)
    instance_count = optional(number, 2)
    instance_class = optional(string, "db.serverless")

    vpc_id                     = string
    private_subnet_ids         = list(string)
    allowed_security_group_ids = optional(list(string), [])

    backup_retention_period          = optional(number, 7)
    preferred_backup_window          = optional(string, "03:00-04:00")
    preferred_maintenance_window     = optional(string, "sun:05:00-sun:06:00")
    deletion_protection              = optional(bool, true)
    skip_final_snapshot              = optional(bool, false)
    enabled_cloudwatch_logs_exports  = optional(list(string), ["postgresql"])
    log_retention_in_days            = optional(number, 365)
    performance_insights_enabled     = optional(bool, true)

    common_tags = optional(map(string), {
      Env       = "dev"
      ManagedBy = "terraform"
      Project   = "default"
    })
  })

  # --- Validation blocks ---

  validation {
    condition     = length(var.aurora_config.database_name) >= 1 && length(var.aurora_config.database_name) <= 63
    error_message = "aurora_config.database_name must be between 1 and 63 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_-]*$", var.aurora_config.database_name))
    error_message = "aurora_config.database_name must start with a letter and contain only alphanumeric characters, underscores, or hyphens. Hyphens are converted to underscores for the PostgreSQL database name."
  }

  validation {
    condition     = var.aurora_config.min_acu >= 0.5 && var.aurora_config.min_acu <= var.aurora_config.max_acu
    error_message = "aurora_config.min_acu must be >= 0.5 and <= max_acu."
  }

  validation {
    condition     = var.aurora_config.max_acu >= 0.5 && var.aurora_config.max_acu <= 256
    error_message = "aurora_config.max_acu must be between 0.5 and 256."
  }

  validation {
    condition     = var.aurora_config.instance_count >= 1 && var.aurora_config.instance_count <= 15
    error_message = "aurora_config.instance_count must be between 1 and 15."
  }

  validation {
    condition     = length(var.aurora_config.private_subnet_ids) >= 2
    error_message = "aurora_config.private_subnet_ids must contain at least 2 subnets."
  }

  validation {
    condition     = var.aurora_config.backup_retention_period >= 1 && var.aurora_config.backup_retention_period <= 35
    error_message = "aurora_config.backup_retention_period must be between 1 and 35 days."
  }
}
