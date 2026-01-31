output "app_name" {
  description = "Logical application name used for naming and resource scoping."
  value       = var.app_name
}

output "app_port" {
  description = "Container port exposed by the application."
  value       = var.port
}

output "deployment_strategy" {
  description = "Deployment strategy for the ECS service (rolling or blue_green)."
  value       = var.deployment_strategy
}

output "healthcheck_endpoint" {
  description = "HTTP healthcheck endpoint used by ALB and ECS health checks."
  value       = var.healthcheck_endpoint
}

output "app_url" {
  description = "Primary HTTPS URL for the app when root domain is configured in base remote state."
  value       = local.root_domain != null ? "https://${var.app_name}.${local.root_domain}" : null
}

output "app_host_header" {
  description = "Host header used by the ALB listener rule for routing."
  value       = local.root_domain != null ? "${var.app_name}.${local.root_domain}" : null
}

output "log_group_name" {
  description = "CloudWatch Logs group name used for ECS task and pipeline logs."
  value       = local.log_group_name
}

output "path_prefix" {
  description = "Base path prefix resolved from base_outputs.path_prefix_map for this app."
  value       = local.path_prefix
}

output "ssm_secret_path_prefix" {
  description = "SSM Parameter Store secret path prefix resolved from base outputs."
  value       = local.ssm_secret_path_prefix
}

output "sns_topic_arn" {
  description = "SNS topic ARN for CodePipeline and deployment notifications."
  value       = aws_sns_topic.codepipeline_notifications.arn
}

output "sns_kms_key_arn" {
  description = "KMS key ARN used to encrypt the SNS topic."
  value       = aws_kms_key.sns_topic.arn
}

output "sns_kms_alias" {
  description = "KMS alias name used for the SNS topic key."
  value       = aws_kms_alias.sns_topic.name
}

output "ecs_cluster_id" {
  description = "ECS cluster id from remote state."
  value       = local.ecs_cluster_outputs.ecs_cluster_id
}

output "ecs_cluster_name" {
  description = "ECS cluster name from remote state."
  value       = local.ecs_cluster_outputs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "ECS service name created for this app."
  value       = module.ecs_service.ecs_service_name
}

output "ecs_task_definition_arn" {
  description = "ECS task definition ARN for the app."
  value       = module.ecs_service.ecs_task_definition_arn
}

output "ecs_task_role_name" {
  description = "IAM role name assumed by the ECS task."
  value       = module.ecs_service.ecs_task_role_name
}

output "ecs_task_definition_family" {
  description = "ECS task definition family for the app."
  value       = module.ecs_service.ecs_task_definition_family
}

output "ecs_task_definition_revision" {
  description = "ECS task definition revision number for the app."
  value       = module.ecs_service.ecs_task_definition_revision
}

output "task_name" {
  description = "Task or service name prefix used across resources."
  value       = local.task_name
}

output "app_image" {
  description = "Full ECR image reference used by the ECS task definition."
  value       = local.ecs_service_config.app_image
}

output "target_group_blue_arn" {
  description = "Target group ARN used for production traffic."
  value       = module.target_group.tg_arn
}

output "target_group_blue_name" {
  description = "Target group name used for production traffic."
  value       = module.target_group.tg_name
}

output "target_group_green_arn" {
  description = "Target group ARN used for green traffic when using blue_green."
  value       = try(module.target_group_green[0].tg_arn, null)
}

output "target_group_green_name" {
  description = "Target group name used for green traffic when using blue_green."
  value       = try(module.target_group_green[0].tg_name, null)
}

output "prod_listener_arn" {
  description = "ALB HTTPS listener ARN used for production traffic routing."
  value       = local.listener_443_arn
}

output "test_listener_arn" {
  description = "ALB test listener ARN used by CodeDeploy for blue_green."
  value       = try(aws_lb_listener.test_8080.arn, null)
}

output "codedeploy_app_name" {
  description = "CodeDeploy application name when using blue_green."
  value       = local.deployment_strategy == "blue_green" ? local.codepipeline_config.codedeploy_app : null
}

output "codedeploy_deployment_group_name" {
  description = "CodeDeploy deployment group name when using blue_green."
  value       = local.deployment_strategy == "blue_green" ? local.codepipeline_config.codedeploy_dg : null
}

output "git_repo" {
  description = "GitHub repository used by the pipeline source action."
  value       = var.git_repo
}

output "git_branch" {
  description = "Git branch used by the pipeline source action."
  value       = var.git_branch
}

output "image_repo" {
  description = "ECR repository name used by the build."
  value       = var.image_repo
}

output "image_tag" {
  description = "Image tag input used by the service config."
  value       = var.image_tag
}

# App
output "app" {
  description = "Application-level configuration and routing details."
  value = {
    name               = var.app_name
    port               = var.port
    deployment_strategy = var.deployment_strategy
    healthcheck_endpoint = var.healthcheck_endpoint
    url                = local.root_domain != null ? "https://${var.app_name}.${local.root_domain}" : null
    host_header        = local.root_domain != null ? "${var.app_name}.${local.root_domain}" : null
    image              = local.ecs_service_config.app_image
    task_name          = local.task_name
  }
}

# Logging and Secrets
output "runtime" {
  description = "Runtime logging and secret resolution paths."
  value = {
    log_group_name          = local.log_group_name
    path_prefix             = local.path_prefix
    ssm_secret_path_prefix  = local.ssm_secret_path_prefix
  }
}

# ECS
output "ecs" {
  description = "ECS cluster, service, and task definition outputs."
  value = {
    cluster_id                   = local.ecs_cluster_outputs.ecs_cluster_id
    cluster_name                 = local.ecs_cluster_outputs.ecs_cluster_name
    service_name                 = module.ecs_service.ecs_service_name
    task_definition_arn          = module.ecs_service.ecs_task_definition_arn
    task_definition_family       = module.ecs_service.ecs_task_definition_family
    task_definition_revision     = module.ecs_service.ecs_task_definition_revision
    task_role_name               = module.ecs_service.ecs_task_role_name
  }
}

# Load Balancing
output "alb" {
  description = "ALB listeners and target groups."
  value = {
    prod_listener_arn        = local.listener_443_arn
    test_listener_arn        = try(aws_lb_listener.test_8080.arn, null)

    target_group_blue = {
      arn  = module.target_group.tg_arn
      name = module.target_group.tg_name
    }

    target_group_green = {
      arn  = try(module.target_group_green[0].tg_arn, null)
      name = try(module.target_group_green[0].tg_name, null)
    }
  }
}

# CI/CD and Notifications
output "pipeline" {
  description = "CI/CD, CodeDeploy, and notification resources."
  value = {
    git_repo   = var.git_repo
    git_branch = var.git_branch
    image_repo = var.image_repo
    image_tag  = var.image_tag

    codedeploy = local.deployment_strategy == "blue_green" ? {
      app_name              = local.codepipeline_config.codedeploy_app
      deployment_group_name = local.codepipeline_config.codedeploy_dg
    } : null

    notifications = {
      sns_topic_arn   = aws_sns_topic.codepipeline_notifications.arn
      kms_key_arn     = aws_kms_key.sns_topic.arn
      kms_alias       = aws_kms_alias.sns_topic.name
    }
  }
}




