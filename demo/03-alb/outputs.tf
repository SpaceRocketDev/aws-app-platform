# output "base_config" {
#   description = "Base configuration map exported for downstream stacks (apps, cluster, etc.) via remote state."
#   value       = local.base_config
# }

# output "base_outputs" {
#   description = "All base primitives as a single object for downstream stacks via remote state."
#   value = {
#     # === Common Metadata ===
#     account_id  = local.account_id
#     env         = var.env
#     project     = var.project
#     aws_region  = var.aws_region
#     region      = var.aws_region
#     admin_email = var.admin_email
#     cert_arn    = var.cert_arn
#     allowed_ips = var.allowed_ips
#     app_names   = var.app_names
#     name_prefix = local.base_config.name_prefix

#     # === Network Outputs ===
#     vpc_id             = module.network.vpc.id
#     public_subnet_ids  = module.network.subnets_public
#     private_subnet_ids = module.network.subnets_private

#     # === ALB Outputs ===
#     alb_listener_443_arn = module.alb.listener_443_arn
#     alb_arn_suffix       = module.alb.arn_suffix
#     alb_dns_name         = module.alb.alb_dns_name
#     alb_arn              = module.alb.alb_arn
#     alb_sg_id            = module.alb.alb_sg_id

#     # === SNS Outputs ===
#     alarm_sns_topic_arn = module.sns_dev_alerts.topic_arn
#     sns_topic_arn       = module.sns_dev_alerts.topic_arn
#     sns_topic_name      = module.sns_dev_alerts.topic_name

#     # === Locals-Based Outputs ===
#     fqdn_map                 = local.base_config.fqdn_map
#     ssm_secret_path_prefixes = local.base_config.ssm_secret_path_prefixes
#     ssm_secret_path_prefix_map = {
#       for idx, app in var.app_names :
#       app => local.base_config.ssm_secret_path_prefixes[idx]
#     }
#     path_prefixes = local.base_config.path_prefixes
#     path_prefix_map = {
#       for idx, app in var.app_names :
#       app => trimsuffix(local.base_config.path_prefixes[idx], "/")
#     }
#   }
# }

# # -----------------------------------------------------------------------------
# # Duplicated, individually-described outputs (for terraform-docs and consumers)
# # -----------------------------------------------------------------------------

# # === base_config: Identity + Naming ===

# output "account_id" {
#   description = "AWS account ID for the deployment. In demos this is derived at runtime for portability; for production prefer an explicitly managed static mapping for any account-specific values."
#   value       = local.base_config.account_id
# }

# output "base_domain" {
#   description = "Base DNS domain for the environment (used to derive main_domain and fqdn_map)."
#   value       = local.base_config.base_domain
# }

# output "project" {
#   description = "Project identifier used for naming and tagging across the stack."
#   value       = local.base_config.project
# }

# output "project_name" {
#   description = "Derived project name in the form '<project>-<env>' used for consistent naming."
#   value       = local.base_config.project_name
# }

# output "name_prefix" {
#   description = "Shared name prefix used for naming resources and app task names in downstream modules."
#   value       = local.base_config.name_prefix
# }

# output "env" {
#   description = "Environment name (for example: dev, stage, prod). Used for naming, logs prefixing, and tags."
#   value       = local.base_config.env
# }

# output "aws_region" {
#   description = "AWS region used by base and downstream stacks."
#   value       = local.base_config.aws_region
# }

# output "region" {
#   description = "Alias of aws_region for downstream compatibility."
#   value       = local.base_config.aws_region
# }

# output "admin_email" {
#   description = "Administrative email address used for alerting and notifications."
#   value       = var.admin_email
# }

# output "allowed_ips" {
#   description = "Allowlist of public IPs or CIDRs used to restrict access where applicable."
#   value       = local.base_config.allowed_ips
# }

# output "natgw_count" {
#   description = "NAT gateway sizing selector passed into the network module (controls number of NAT gateways)."
#   value       = local.base_config.natgw_count
# }

# output "common_tags" {
#   description = "Standard tags applied across resources (merged into downstream stacks)."
#   value       = local.base_config.common_tags
# }

# # === base_config: ALB and Domain settings ===

# output "lb_ssl_policy" {
#   description = "ALB TLS policy name used by listeners (also referenced by downstream test listeners)."
#   value       = local.base_config.lb_ssl_policy
# }

# output "main_domain" {
#   description = "Primary domain name used by the ALB and DNS records (typically equals base_domain)."
#   value       = local.base_config.main_domain
# }

# output "additional_domains" {
#   description = "Additional domain names to include on the ALB certificate and/or DNS aliases."
#   value       = local.base_config.additional_domains
# }

# output "fqdn_map" {
#   description = "Map of logical names to fully qualified domain names used by downstream stacks (for example, 'root' lookup)."
#   value       = local.base_config.fqdn_map
# }

# # === base_config: Logging defaults ===

# output "logs_enabled" {
#   description = "Whether ALB access logging is enabled for the environment."
#   value       = local.base_config.logs_enabled
# }

# output "logs_prefix" {
#   description = "S3 log prefix for ALB access logs (commonly set to env)."
#   value       = local.base_config.logs_prefix
# }

# output "logs_bucket" {
#   description = "S3 bucket name used for ALB access logs."
#   value       = local.base_config.logs_bucket
# }

# output "logs_expiration" {
#   description = "S3 lifecycle expiration in days for access log objects."
#   value       = local.base_config.logs_expiration
# }

# output "logs_bucket_force_destroy" {
#   description = "Whether the logs bucket may be force-destroyed (generally false for safety)."
#   value       = local.base_config.logs_bucket_force_destroy
# }

# # === base_config: Alarm thresholds and SNS naming ===

# output "alb_5xx_threshold" {
#   description = "Threshold for ALB HTTP 5xx alarms."
#   value       = local.base_config.alb_5xx_threshold
# }

# output "target_5xx_threshold" {
#   description = "Threshold for target HTTP 5xx alarms."
#   value       = local.base_config.target_5xx_threshold
# }

# output "topic_name" {
#   description = "SNS topic name used by the base alerts topic."
#   value       = local.base_config.topic_name
# }

# # === base_config: App routing and SSM helpers ===

# output "path_prefixes" {
#   description = "List of per-app ALB path prefixes (used by downstream stacks for routing and naming)."
#   value       = local.base_config.path_prefixes
# }

# output "ssm_secret_path_prefixes" {
#   description = "List of per-app SSM parameter path prefixes used by downstream stacks to locate secrets."
#   value       = local.base_config.ssm_secret_path_prefixes
# }

# # === base_outputs: Certificate ===

# output "cert_arn" {
#   description = "ACM certificate ARN used by the ALB listener(s) and downstream test listeners."
#   value       = var.cert_arn
# }

# # === base_outputs: Network ===

# output "vpc_id" {
#   description = "VPC ID for the environment (consumed by downstream stacks)."
#   value       = module.network.vpc.id
# }

# output "public_subnet_ids" {
#   description = "Public subnet IDs created by the base network module."
#   value       = module.network.subnets_public
# }

# output "private_subnet_ids" {
#   description = "Private subnet IDs created by the base network module (used for Fargate tasks in downstream stacks)."
#   value       = module.network.subnets_private
# }

# # === base_outputs: ALB ===

# output "alb_listener_443_arn" {
#   description = "ARN of the ALB HTTPS (443) listener used by downstream ECS services."
#   value       = module.alb.listener_443_arn
# }

# output "alb_arn_suffix" {
#   description = "ALB ARN suffix used for CloudWatch metrics and alarms."
#   value       = module.alb.arn_suffix
# }

# output "alb_dns_name" {
#   description = "ALB DNS name used for DNS aliasing and validation."
#   value       = module.alb.alb_dns_name
# }

# output "alb_arn" {
#   description = "ALB ARN used by downstream resources (for example, test listeners)."
#   value       = module.alb.alb_arn
# }

# output "alb_sg_id" {
#   description = "Security group ID attached to the ALB (referenced by downstream stacks)."
#   value       = module.alb.alb_sg_id
# }

# # === base_outputs: SNS ===

# output "alarm_sns_topic_arn" {
#   description = "SNS topic ARN used for base alarms and notifications."
#   value       = module.sns_dev_alerts.topic_arn
# }

# output "sns_topic_arn" {
#   description = "Alias of alarm_sns_topic_arn for downstream compatibility."
#   value       = module.sns_dev_alerts.topic_arn
# }

# output "sns_topic_name" {
#   description = "SNS topic name used for base alerts and downstream integrations."
#   value       = module.sns_dev_alerts.topic_name
# }

# # === base_outputs: App helpers (maps) ===

# output "app_names" {
#   description = "List of application identifiers used to build routing and secret path maps."
#   value       = var.app_names
# }

# output "ssm_secret_path_prefix_map" {
#   description = "Map of app name to SSM parameter path prefix used by downstream stacks to resolve per-app secret locations."
#   value = {
#     for idx, app in var.app_names :
#     app => local.base_config.ssm_secret_path_prefixes[idx]
#   }
# }

# output "path_prefix_map" {
#   description = "Map of app name to normalized ALB path prefix (trailing slash removed) used by downstream ECS services."
#   value = {
#     for idx, app in var.app_names :
#     app => trimsuffix(local.base_config.path_prefixes[idx], "/")
#   }
# }
