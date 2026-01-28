# Interface VPC Endpoint for AWS Systems Manager (SSM) with Private DNS enabled
resource "aws_vpc_endpoint" "ssm" {
  service_name        = "com.amazonaws.${var.network_config.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  vpc_id              = aws_vpc.main.id
  security_group_ids  = [aws_security_group.ssm_vpc.id]
  private_dns_enabled = true
  tags = merge(local.common_tags, {
    Name = local.name_prefix
  })
}

# Associate the SSM VPC Endpoint with all public subnets
resource "aws_vpc_endpoint_subnet_association" "ssm_public" {
  count           = length(aws_subnet.public)
  vpc_endpoint_id = aws_vpc_endpoint.ssm.id
  subnet_id       = element(aws_subnet.public[*].id, count.index)
}

# Interface VPC Endpoint for AWS Secrets Manager with Private DNS enabled
resource "aws_vpc_endpoint" "secretsmanager" {
  service_name        = "com.amazonaws.${var.network_config.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  vpc_id              = aws_vpc.main.id
  security_group_ids  = [aws_security_group.ssm_vpc.id]
  private_dns_enabled = true
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-secretsmanager" })
}

# Associate the Secrets Manager VPC Endpoint with all private subnets
resource "aws_vpc_endpoint_subnet_association" "secretsmanager_private" {
  count           = length(aws_subnet.private)
  vpc_endpoint_id = aws_vpc_endpoint.secretsmanager.id
  subnet_id       = element(aws_subnet.private[*].id, count.index)
}
