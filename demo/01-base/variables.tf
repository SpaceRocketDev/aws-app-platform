variable "org" {
  description = "Organization or company identifier used for naming and tags."
  type        = string
}

variable "project" {
  description = "Project identifier used for naming and tags."
  type        = string
}

variable "env" {
  description = "Environment name, for example: dev, staging, prod."
  type        = string
}

variable "aws_region" {
  description = "AWS region used by the root provider configuration."
  type        = string
}

variable "extra_tags" {
  description = "Optional extra tags merged into common_tags."
  type        = map(string)
  default     = {}
}

variable "app_names" {
  type        = list(string)
  description = "List of application subdomain prefixes used to generate fqdn_map, Route53 alias records, and per-app SSM/path prefixes. Use an empty string to represent the root domain."
  default     = ["", "app"]
}
