variable "state_bucket" {
  description = "S3 bucket storing the base stack Terraform state"
  type        = string
}

variable "base_state_key" {
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