# Customer-managed Elastic IPs for NAT Gateway egress (stable allowlist targets)
resource "aws_eip" "ngw" {
  # NOTE: This module only creates customer-managed Elastic IPs for NAT Gateway egress.
  # You may still see additional public IPs in the AWS console (for example, attached to ALB-owned ENIs).
  # Those are AWS-managed service addresses, not EIPs created by this module, and should not be treated as
  # stable allowlist targets or "customer-owned" IPs.
  count  = local.natgw_count
  domain = "vpc"

  depends_on = [aws_internet_gateway.igw]

  tags = merge(local.common_tags, {
    Name = format("%s-natgw-%d", local.name_prefix, count.index + 1)
  })
}

# NAT Gateways providing private subnet egress via the public subnets
resource "aws_nat_gateway" "ngw" {
  count             = local.natgw_count
  subnet_id         = aws_subnet.public[count.index].id
  allocation_id     = aws_eip.ngw[count.index].id
  connectivity_type = "public"

  depends_on = [aws_internet_gateway.igw]

  tags = merge(local.common_tags, {
    Name = format("%s-%d", local.name_prefix, count.index + 1)
  })
}
