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

# output "sg_ecs_fargate_task" {
#   value = aws_security_group.ecs_fargate_task
# }