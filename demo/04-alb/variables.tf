variable "state_bucket" {
  description = "S3 bucket storing the base stack Terraform state"
  type        = string
}

variable "base_state_key" {
  description = "State key for the base stack"
  type        = string
}

variable "network_state_key" {
  description = "State key for the network stack"
  type        = string
}

variable "sns_state_key" {
  description = "State key for the sns stack"
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table used for Terraform state locking"
  type        = string
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy into. Used for provider configuration, regional service ARNs, and region-specific resources (for example, ELB log delivery account mapping)."
  default     = "us-east-1"
}

variable "cert_arn" {
  type        = string
  description = "ACM certificate ARN used by the ALB HTTPS listener as the primary TLS certificate (passed as main_cert_arn)."
  default     = ""
}

variable "additional_cert_arn" {
  type        = string
  description = "Additional ACM certificate ARN reserved for future use (not currently passed into the ALB module configuration)."
  default     = ""
}

variable "allowed_ips" {
  type        = list(string)
  description = "IPv4 addresses allowed to reach the public ALB. Values can be plain IPs (x.x.x.x) or CIDRs. Plain IPs are normalized to /32 for security group rules."
  default     = ["0.0.0.0/0"]
}

variable "app_names" {
  type        = list(string)
  description = "List of application subdomain prefixes used to generate fqdn_map, Route53 alias records, and per-app SSM/path prefixes. Use an empty string to represent the root domain."
  default     = ["", "app"]
}

variable "base_domain" {
  type        = string
  description = "Base DNS domain hosted in Route53. Used to generate per-app FQDNs (for example, app.base_domain and base_domain) and create ALB alias records."
  default     = "example.com"
}

variable "enable_waf" {
  type        = bool
  description = "Attach a WAF v2 Web ACL to the ALB."
  default     = true
}
