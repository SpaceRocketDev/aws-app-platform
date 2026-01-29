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
