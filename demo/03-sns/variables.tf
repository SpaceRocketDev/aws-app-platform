variable "state_bucket" {
  description = "S3 bucket storing the stacks Terraform states"
  type        = string
}

variable "state_key" {
  description = "State key for the base stack"
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table used for Terraform state locking"
  type        = string
}

variable "aws_region" {
  type = string
}

variable "admin_email" {
  type        = string
  description = "Email address subscribed to the SNS alerts topic for CloudWatch alarms (ALB 5xx and target 5xx)."
  default     = "admin@example.com"
}