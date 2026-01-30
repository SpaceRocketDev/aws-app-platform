variable "base_state_bucket" {
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

variable "natgw_count" {
  type        = string
  description = "NAT Gateway strategy for the VPC. Supported values: \"none\" (0 NAT gateways), \"one\" (single NAT gateway), \"all\" (one NAT gateway per AZ). Affects NAT EIPs that are also allow-listed on the ALB security group."
  default     = "one"
}
