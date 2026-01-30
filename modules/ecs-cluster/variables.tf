# variables.tf

variable "ecs_cluster_config" {
  description = "Composite config for ECS cluster naming, account and region context, and secret path prefixes used for execution-role SSM access policies."

  type = object({
    env                      = string
    account_id               = string
    aws_region               = string
    project                  = string
    name_prefix              = string
    ssm_secret_path_prefixes = list(string)
    cluster_name_override    = string
  })

  default = {
    env                      = "dev"
    account_id               = "000000000000"
    aws_region               = "NOTSET"
    project                  = "default"
    name_prefix              = "default-dev"
    ssm_secret_path_prefixes = ["/default/"]
    cluster_name_override    = ""
  }
}
