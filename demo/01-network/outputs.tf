output "network" {
  description = "All base primitives as a single object for downstream stacks via remote state."
  value = {
    # === Common Metadata ===
    account_id  = local.account_id
    env         = var.env
    project     = var.project
    aws_region  = var.aws_region
    region      = var.aws_region
    name_prefix = module.network.name_prefix

    # === Network Outputs ===
    vpc_id             = module.network.vpc.id
    public_subnet_ids  = module.network.subnets_public
    private_subnet_ids = module.network.subnets_private
    nat_gateway_eips   = module.network.nat_gateway_eips

  }
}

output "network2" {
  description = "Network primitives for downstream stacks via remote state."
  value       = module.network.network
}
