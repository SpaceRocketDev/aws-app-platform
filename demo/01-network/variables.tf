# variables.tf
variable "env" {
  type        = string
  description = "Deployment environment identifier (for example: dev, staging, prod). Used in name_prefix, tags, log prefixes, and DNS/SSM path construction."
  default     = "dev"
}

variable "org" {
  type        = string
  description = "Organization or tenant identifier used to build name_prefix and hierarchical paths (org/project/env) for SSM and routing."
  default     = "example"
}

variable "project" {
  type        = string
  description = "Project identifier used in name_prefix, tags, logs bucket naming, and routing/SSM path construction."
  default     = "demo"
}

variable "admin_email" {
  type        = string
  description = "Email address subscribed to the SNS alerts topic for CloudWatch alarms (ALB 5xx and target 5xx)."
  default     = "admin@example.com"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy into. Used for provider configuration, regional service ARNs, and region-specific resources (for example, ELB log delivery account mapping)."
  default     = "us-east-1"
}

variable "natgw_count" {
  type        = string
  description = "NAT Gateway strategy for the VPC. Supported values: \"none\" (0 NAT gateways), \"one\" (single NAT gateway), \"all\" (one NAT gateway per AZ). Affects NAT EIPs that are also allow-listed on the ALB security group."
  default     = "one"
}
