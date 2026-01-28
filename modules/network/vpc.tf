# Primary VPC for the stack (DNS enabled, IPv6 assigned)
resource "aws_vpc" "main" {
  cidr_block           = var.network_config.vpc_ip_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  assign_generated_ipv6_cidr_block = true

  tags = merge(var.network_config.common_tags, {
    Name = var.network_config.project_name
  })
}

# Internet Gateway for public subnet egress/ingress
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = var.network_config.project_name
  })
}
