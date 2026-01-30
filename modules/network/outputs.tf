output "name_prefix" {
  description = "Name prefix used for resources created by this module."
  value       = local.name_prefix
}

output "vpc" {
  value = aws_vpc.main
}

output "subnets_private" {
  value = aws_subnet.private
}

output "subnets_public" {
  value = aws_subnet.public
}

output "nat_gateway_eips" {
  description = "List of NAT Gateway Elastic IP addresses"
  value       = aws_eip.ngw[*].public_ip
}

output "natgw_count" {
  description = "NAT Gateway strategy for private subnet egress. Valid values: \"none\" (no NAT Gateways), \"one\" (single shared NAT Gateway), or \"all\" (one NAT Gateway per Availability Zone)."
  value       = local.natgw_count
}

output "network" {
  description = "Network primitives for downstream stacks via remote state (stable contract)."
  value = {
    account_id   = var.network_config.account_id
    aws_region   = var.network_config.aws_region
    region       = var.network_config.aws_region
    name_prefix  = local.name_prefix

    vpc_id = aws_vpc.main.id

    public_subnet_ids  = [for s in aws_subnet.public : s.id]
    private_subnet_ids = [for s in aws_subnet.private : s.id]
    nat_gateway_eips = try(
      [for e in aws_eip.ngw : e.public_ip],
      []
    )
  }
}


