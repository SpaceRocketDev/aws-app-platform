variable "network_config" {
  description = "Composite config for VPC, subnets, NAT strategy, endpoints, and tags."

  type = object({
    name_prefix = optional(string, "myapp-dev")
    account_id  = optional(string, "")
    aws_region  = optional(string, "us-east-1")

    az_num = optional(number, 3)

    vpc_ip_block = optional(string, "172.27.72.0/22")

    subnet_cidr_private = optional(string, "172.27.72.0/24")
    subnet_cidr_public  = optional(string, "172.27.73.0/24")

    new_bits_private = optional(number, 2)
    new_bits_public  = optional(number, 2)

    natgw_count = optional(string, "none") # none | one | all

    common_tags = optional(map(string), {
      Env       = "dev"
      ManagedBy = "terraform"
      Project   = "default"
    })
  })

  validation {
    condition = contains(
      ["none", "one", "all"],
      var.network_config.natgw_count
    )
    error_message = "network_config.natgw_count must be one of: none, one, or all."
  }

  validation {
    condition     = var.network_config.az_num >= 1 && var.network_config.az_num <= 6
    error_message = "network_config.az_num must be between 1 and 6."
  }

  validation {
    condition     = can(cidrnetmask(var.network_config.vpc_ip_block))
    error_message = "network_config.vpc_ip_block must be a valid CIDR block."
  }

  validation {
    condition = alltrue([
      can(cidrnetmask(var.network_config.subnet_cidr_private)),
      can(cidrnetmask(var.network_config.subnet_cidr_public))
    ])
    error_message = "Private and public subnet CIDRs must be valid CIDR blocks."
  }

  validation {
    condition     = var.network_config.new_bits_private >= 1 && var.network_config.new_bits_public >= 1
    error_message = "new_bits_private and new_bits_public must be >= 1."
  }
}
