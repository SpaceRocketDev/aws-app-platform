########################
# ECS Task Definition
########################
# Template for container definitions
locals {
  # log_stream_prefix = "${formatdate("yyyy-MM-dd", timestamp())}"
  # log_stream_prefix = "${formatdate("YYYY-MM-DD", timestamp())}"

  app_template_path = "${path.module}/app.json"

  app_config = templatefile(
    local.app_template_path,
    {
      healthcheck_interval     = var.ecs_service_config.healthcheck_interval
      healthcheck_timeout      = var.ecs_service_config.healthcheck_timeout
      healthcheck_retries      = var.ecs_service_config.healthcheck_retries
      healthcheck_start_period = var.ecs_service_config.healthcheck_start_period
      healthcheck_endpoint = var.ecs_service_config.healthcheck_endpoint
      task_name        = var.ecs_service_config.task_name
      log_group_name   = var.ecs_service_config.log_group_name
      app_name         = var.ecs_service_config.app_name
      app_image        = var.ecs_service_config.app_image
      app_port         = var.ecs_service_config.app_port
      app_env          = var.ecs_service_config.env
      project          = var.ecs_service_config.project
      region           = var.ecs_service_config.region
      account_id       = var.ecs_service_config.account_id
      fargate_cpu      = var.ecs_service_config.fargate_cpu
      fargate_memory   = var.ecs_service_config.fargate_memory
      app_environments = jsonencode(var.ecs_service_config.app_environments)
      app_secrets      = jsonencode(var.ecs_service_config.app_secrets)
    }
  )
}


# ECS task definition for the Hello World application
resource "aws_ecs_task_definition" "app" {
  family                   = var.ecs_service_config.task_name
  container_definitions    = local.app_config
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_service_config.fargate_cpu
  memory                   = var.ecs_service_config.fargate_memory

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.ecs_service_config.runtime_platform
  }

  execution_role_arn = var.ecs_service_config.ecs_execution_role
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  tags = {
    app_json_hash = filemd5("${path.module}/app.json")
  }
}

########################
# ECS Service
########################
# resource "aws_ecs_service" "ecs_app_service" {
#   name                   = "${var.ecs_service_config.task_name}-fargate-service"
#   cluster                = var.ecs_service_config.ecs_cluster_id
#   task_definition        = aws_ecs_task_definition.app.arn
#   desired_count          = var.ecs_service_config.app_count
#   enable_execute_command = true

#   capacity_provider_strategy {
#     capacity_provider = "FARGATE_SPOT"
#     weight            = 2
#   }

#   capacity_provider_strategy {
#     capacity_provider = "FARGATE"
#     weight            = 1
#     base              = 1
#   }

#   network_configuration {
#     security_groups = [aws_security_group.ecs_fargate_task.id]
#     subnets          = var.ecs_service_config.fargate_subnets[*].id
#     assign_public_ip = var.ecs_service_config.assign_public_ip
#   }

#   load_balancer {
#     target_group_arn = var.ecs_service_config.tg_arn
#     container_name   = var.ecs_service_config.task_name
#     container_port   = var.ecs_service_config.app_port
#   }

# }
# ECS service used for rolling deployments
resource "aws_ecs_service" "ecs_app_service_rolling" {
  for_each               = var.ecs_service_config.deployment_strategy == "rolling" ? { this = 1 } : {}
  name                   = "${var.ecs_service_config.task_name}-fargate-service"
  cluster                = var.ecs_service_config.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.app.arn
  desired_count          = var.ecs_service_config.app_count
  enable_execute_command = true

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 2
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_fargate_task.id]
    subnets          = var.ecs_service_config.fargate_subnets[*].id
    assign_public_ip = var.ecs_service_config.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.ecs_service_config.tg_arn
    container_name   = var.ecs_service_config.task_name
    container_port   = var.ecs_service_config.app_port
  }
}

# ECS service controlled by CodeDeploy for blue green deployments
resource "aws_ecs_service" "ecs_app_service_codedeploy" {
  for_each               = var.ecs_service_config.deployment_strategy == "blue_green" ? { this = 1 } : {}
  name                   = "${var.ecs_service_config.task_name}-fargate-service"
  cluster                = var.ecs_service_config.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.app.arn
  desired_count          = var.ecs_service_config.app_count
  enable_execute_command = true

  deployment_controller { type = "CODE_DEPLOY" }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 2
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_fargate_task.id]
    subnets          = var.ecs_service_config.fargate_subnets[*].id
    assign_public_ip = var.ecs_service_config.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.ecs_service_config.blue_tg_arn
    container_name   = var.ecs_service_config.task_name
    container_port   = var.ecs_service_config.app_port
  }
}

