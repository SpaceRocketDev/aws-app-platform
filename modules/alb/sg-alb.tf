resource "aws_security_group" "alb" {
  description = "Alb ${upper(var.alb_config.env)}"
  name        = "${local.name_prefix}-alb"
  vpc_id      = var.alb_config.vpc.id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
  })
}

### EGRESS
resource "aws_security_group_rule" "alb_egress" {
  description = "Alb ${upper(var.alb_config.env)} Egress"
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"

  cidr_blocks       = ["0.0.0.0/0"] # tfsec:ignore:AWS007
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_egress_v6" {
  description = "Alb ${upper(var.alb_config.env)} Egress"
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"

  ipv6_cidr_blocks  = ["::/0"] # tfsec:ignore:AWS007
  security_group_id = aws_security_group.alb.id
}

### ICMP

# resource "aws_security_group_rule" "alb_icmp" {
#   description = "Alb ${upper(var.alb_config.env)} ICMP"
#   type        = "ingress"
#   from_port   = -1
#   to_port     = -1
#   protocol    = "icmp"

#   cidr_blocks       = ["0.0.0.0/0"] # tfsec:ignore:AWS006
#   security_group_id = aws_security_group.alb.id
# }

# resource "aws_security_group_rule" "alb_icmp_v6" {
#   description = "Alb ${upper(var.alb_config.env)} ICMP"
#   type        = "ingress"
#   from_port   = -1
#   to_port     = -1
#   protocol    = "icmpv6"


#   ipv6_cidr_blocks  = ["::/0"] # tfsec:ignore:AWS006
#   security_group_id = aws_security_group.alb.id
# }

### FROM PUBLIC IPS
resource "aws_security_group_rule" "alb_80" {
  count = length(var.alb_config.public_ips)

  description = values(var.alb_config.public_ips)[count.index]
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = [keys(var.alb_config.public_ips)[count.index]]

  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_8080" {
  count = length(var.alb_config.public_ips)
  description = values(var.alb_config.public_ips)[count.index]
  type        = "ingress"
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = [keys(var.alb_config.public_ips)[count.index]]
  security_group_id = aws_security_group.alb.id
}
resource "aws_security_group_rule" "alb_443" {
  count = length(var.alb_config.public_ips)

  description = values(var.alb_config.public_ips)[count.index]
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = [keys(var.alb_config.public_ips)[count.index]]

  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_80_v6" {
  count = length(var.alb_config.public_ips_v6)

  description      = values(var.alb_config.public_ips)[count.index]
  type             = "ingress"
  from_port        = 80
  to_port          = 80
  protocol         = "tcp"
  ipv6_cidr_blocks = [keys(var.alb_config.public_ips_v6)[count.index]]

  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_8080_v6" {
  count = length(var.alb_config.public_ips_v6)
  description      = values(var.alb_config.public_ips)[count.index]
  type             = "ingress"
  from_port        = 8080
  to_port          = 8080
  protocol         = "tcp"
  ipv6_cidr_blocks = [keys(var.alb_config.public_ips_v6)[count.index]]
  security_group_id = aws_security_group.alb.id
}
resource "aws_security_group_rule" "alb_443_v6" {
  count = length(var.alb_config.public_ips_v6)

  description      = values(var.alb_config.public_ips)[count.index]
  type             = "ingress"
  from_port        = 443
  to_port          = 443
  protocol         = "tcp"
  ipv6_cidr_blocks = [keys(var.alb_config.public_ips_v6)[count.index]]

  security_group_id = aws_security_group.alb.id
}

# Move these to the ecs-service
# Allow scrapes from ECS tasks (Prometheus) directly by SG
# resource "aws_security_group_rule" "alb_443_from_tasks" {
#   description              = "Allow HTTPS from ECS tasks"
#   type                     = "ingress"
#   from_port                = 443
#   to_port                  = 443
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.alb.id
#   source_security_group_id = aws_security_group.ecs_fargate_task.id
# }

# resource "aws_security_group_rule" "alb_80_from_tasks" {
#   description              = "Allow HTTP from ECS tasks"
#   type                     = "ingress"
#   from_port                = 80
#   to_port                  = 80
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.alb.id
#   source_security_group_id = aws_security_group.ecs_fargate_task.id
# }

# Extra allow rules for NATGW EIPs
resource "aws_security_group_rule" "alb_80_nat_eips" {
  count = local.natgw_count

  description = "NATGW EIP"
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["${var.alb_config.nat_gateway_eips[count.index]}/32"]

  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_443_nat_eips" {
  count = local.natgw_count

  description = "NATGW EIP"
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["${var.alb_config.nat_gateway_eips[count.index]}/32"]

  security_group_id = aws_security_group.alb.id
}
