# Security group attached to the Fargate task
resource "aws_security_group" "ecs_fargate_task" {
  description = "Security group attached to the Fargate task"
  name        = "${var.ecs_service_config.name_prefix}-${var.ecs_service_config.app_name}-fargate-task-sg"
  vpc_id      = var.ecs_service_config.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.ecs_service_config.common_tags, {
    Name = "${var.ecs_service_config.name_prefix}-${var.ecs_service_config.app_name}-fargate-task-sg"
  })
}

# Allows outbound IPv4 traffic from the ECS task
resource "aws_security_group_rule" "ecs_fargate_task_egress" {
  description = "Allows outbound IPv4 traffic from the ECS task"
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"

  cidr_blocks       = ["0.0.0.0/0"] # tfsec:ignore:AWS007
  security_group_id = aws_security_group.ecs_fargate_task.id
}

# Allows outbound IPv6 traffic from the ECS task
resource "aws_security_group_rule" "ecs_fargate_task_egress_v6" {
  description = "Allows outbound IPv6 traffic from the ECS task"
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"

  ipv6_cidr_blocks  = ["::/0"] # tfsec:ignore:AWS007
  security_group_id = aws_security_group.ecs_fargate_task.id
}

# Allows ALB to reach the application container port
resource "aws_security_group_rule" "from_alb_to_task" {
  description              = "Allows ALB to reach the application container port"
  type                     = "ingress"
  from_port                = var.ecs_service_config.app_port
  to_port                  = var.ecs_service_config.app_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_fargate_task.id
  source_security_group_id = var.ecs_service_config.alb_sg_id

  depends_on = [aws_security_group.ecs_fargate_task]

  lifecycle {
    create_before_destroy = true
  }
}