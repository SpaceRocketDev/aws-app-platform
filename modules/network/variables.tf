variable "network_config" {
  description = "Composite config for VPC, subnets, NAT strategy, endpoints, and tags."

  type = object({
    project_name        = string
    name_prefix         = string
    account_id          = string
    aws_region          = string
    az_num              = number
    vpc_ip_block        = string
    subnet_cidr_private = string
    subnet_cidr_public  = string
    new_bits_private    = number
    new_bits_public     = number
    natgw_count         = string # "none" | "one" | "all"
    common_tags         = map(string)
  })

  default = {
    project_name        = "myapp-dev"
    name_prefix         = "myapp-dev"
    account_id          = ""
    aws_region          = "us-east-1"
    az_num              = 3
    vpc_ip_block        = "172.27.72.0/22"
    subnet_cidr_private = "172.27.72.0/24"
    subnet_cidr_public  = "172.27.73.0/24"
    new_bits_private    = 2
    new_bits_public     = 2
    natgw_count         = "none"
    common_tags = {
      Env       = "dev"
      ManagedBy = "terraform"
      Project   = "default"
    }
  }
}
