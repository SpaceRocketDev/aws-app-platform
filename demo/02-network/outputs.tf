output "network" {
  description = "All base primitives as a single object for downstream stacks via remote state."
  value = {
    vpc_id             = module.network.vpc.id
    public_subnet_ids  = module.network.subnets_public
    private_subnet_ids = module.network.subnets_private
    nat_gateway_eips   = module.network.nat_gateway_eips
  }
}
