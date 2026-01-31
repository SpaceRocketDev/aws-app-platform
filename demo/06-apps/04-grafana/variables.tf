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

variable "alb_state_key" {
  description = "State key for the alb stack"
  type        = string
}

variable "ecs_cluster_state_key" {
  description = "State key for the ecs_cluster stack"
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table used for Terraform state locking"
  type        = string
}

variable "aws_region" {
  type = string
}

variable "app_name" {
  type        = string
  description = "Application name"

  # validation {
  #   condition     = contains(data.terraform_remote_state.base.outputs.base_config.app_names, var.app_name)
  #   error_message = "The provided app_name is not in the list of available app_names from remote state infra/variables-env.tf"
  # }
}

variable "port" {
  type = number
}

variable "image_repo" {
  description = "Name of the ECR image repository"
  type        = string
}

variable "image_tag" {
  description = "Tag of the ECR image to deploy"
  type        = string
}

variable "git_repo" {
  description = "GitHub repo full path, e.g., org/repo"
  type        = string
}

variable "git_branch" {
  description = "Branch name to trigger the pipeline"
  type        = string
  default     = "main"
}

variable "healthcheck_interval" {
  type    = number
  default = 10
}

variable "healthcheck_timeout" {
  type    = number
  default = 5
}

variable "healthcheck_retries" {
  type    = number
  default = 5
}

variable "healthcheck_start_period" {
  type    = number
  default = 30
}

variable "healthcheck_endpoint" {
  type    = string
  default = "/health"
}

variable "codebuild_compute_type" {
  description = "Compute type for CodeBuild (e.g. BUILD_GENERAL1_MEDIUM)"
  type        = string
}

variable "codebuild_image" {
  description = "CodeBuild image to use (e.g. aws/codebuild/amazonlinux-aarch64-standard:3.0)"
  type        = string
}

variable "fargate_cpu" {
  description = "The amount of CPU (in CPU units) to allocate for the Fargate task. Valid values are 256, 512, 1024, 2048, or 4096."
  type        = number
}

variable "fargate_memory" {
  description = "The amount of memory (in MiB) to allocate for the Fargate task. Must be compatible with the selected CPU value."
  type        = number
}

variable "priority" {
  description = "Should be 100 higher then the previous app deployed"
  type        = number
}

variable "deployment_strategy" {
  description = "rolling or blue_green"
  type        = string
  default     = "rolling"
}

