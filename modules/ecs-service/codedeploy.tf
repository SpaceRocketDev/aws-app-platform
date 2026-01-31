# CodeDeploy application for ECS deployments
resource "aws_codedeploy_app" "ecs" {
  for_each         = var.ecs_service_config.deployment_strategy == "blue_green" ? { this = 1 } : {}
  name             = "${var.ecs_service_config.task_name}-cd-app"
  compute_platform = "ECS"
}

# IAM role assumed by CodeDeploy
data "aws_iam_policy_document" "codedeploy_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codedeploy" {
  for_each           = aws_codedeploy_app.ecs
  name               = "${var.ecs_service_config.task_name}-codedeploy-role"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume.json
}

# Attaches AWS managed CodeDeploy ECS policy
resource "aws_iam_role_policy_attachment" "codedeploy_managed" {
  for_each = aws_iam_role.codedeploy
  role     = aws_iam_role.codedeploy["this"].name
  # policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForECS"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# CodeDeploy deployment group managing traffic shifting
resource "aws_codedeploy_deployment_group" "ecs" {
  count               = var.ecs_service_config.deployment_strategy == "blue_green" ? 1 : 0
  # for_each            = aws_codedeploy_app.ecs
  app_name            = aws_codedeploy_app.ecs["this"].name
  deployment_group_name = "${var.ecs_service_config.task_name}-cd-dg"
  service_role_arn    = aws_iam_role.codedeploy["this"].arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  
  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 2
    }
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
  }

  ecs_service {
    cluster_name = var.ecs_service_config.ecs_cluster_name
    service_name = aws_ecs_service.ecs_app_service_codedeploy["this"].name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route { listener_arns = [var.ecs_service_config.prod_listener_arn] }
      test_traffic_route { listener_arns = [coalesce(var.ecs_service_config.test_listener_arn, var.ecs_service_config.prod_listener_arn)] }

      target_group {
        name = coalesce(
          var.ecs_service_config.blue_tg_name,
          split("/", var.ecs_service_config.blue_tg_arn)[length(split("/", var.ecs_service_config.blue_tg_arn)) - 1]
        )
      }
      target_group {
        name = coalesce(
          var.ecs_service_config.green_tg_name,
          split("/", var.ecs_service_config.green_tg_arn)[length(split("/", var.ecs_service_config.green_tg_arn)) - 1]
        )
      }
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
