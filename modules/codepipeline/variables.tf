variable "codepipeline_config" {
  type = object({
    account_id                 = string
    app_name                   = string
    app_secrets                = list(object({ name = string, valueFrom = string }))
    app_environments           = list(object({ name = string, value = string }))
    codebuild_compute_type     = string
    codebuild_image            = string
    ecs_cluster_name           = string
    ecs_service_name           = string
    env                        = string
    fargate_cpu                = number
    fargate_ecs_execution_role = string
    fargate_ecs_task_role      = string
    fargate_memory             = number
    git_branch                 = string
    git_repo                   = string
    healthcheck_endpoint       = string
    image_repo                 = string
    log_group_name             = string
    port                       = number
    project                    = string
    region                     = string
    ssm_secret_path_prefix     = string
    task_name                  = string

    # new for conditional deploy
    deploy_provider            = string              # "ECS" or "CodeDeployToECS"
    codedeploy_app             = optional(string)
    codedeploy_dg              = optional(string)
  })

  default = {
    account_id                 = ""
    app_name                   = "app"
    app_secrets                = []
    app_environments           = []
    codebuild_compute_type     = "BUILD_GENERAL1_SMALL"
    codebuild_image            = "aws/codebuild/standard:7.0"
    ecs_cluster_name           = "default"
    ecs_service_name           = "app"
    env                        = "dev"
    fargate_cpu                = 256
    fargate_ecs_execution_role = ""
    fargate_ecs_task_role      = ""
    fargate_memory             = 512
    git_branch                 = "main"
    git_repo                   = "owner/repo"
    healthcheck_endpoint       = "/"
    image_repo                 = "123456789012.dkr.ecr.us-east-1.amazonaws.com/app"
    log_group_name             = "/ecs/app"
    port                       = 8080
    project                    = "default"
    region                     = "us-east-1"
    ssm_secret_path_prefix     = "/app/dev"
    task_name                  = "app"

    deploy_provider            = "ECS"
    codedeploy_app             = null
    codedeploy_dg              = null
  }
}
