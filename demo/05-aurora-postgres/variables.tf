variable "state_bucket" {
  description = "S3 bucket storing the Terraform state"
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

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "db_name" {
  description = "Name of the initial database to create"
  type        = string
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "16.4"
}

variable "min_acu" {
  description = "Minimum ACU for Serverless v2 scaling"
  type        = number
  default     = 0.5
}

variable "max_acu" {
  description = "Maximum ACU for Serverless v2 scaling"
  type        = number
  default     = 2
}

variable "instance_count" {
  description = "Number of Aurora cluster instances"
  type        = number
  default     = 2
}

variable "deletion_protection" {
  description = "Enable deletion protection on the cluster"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on cluster deletion"
  type        = bool
  default     = false
}
