locals {
  codepipeline_config = {
    account_id = local.account_id
    project    = local.base.project
    env        = local.base.env
    region     = local.region

    app_name             = local.app_name
    task_name            = local.task_name
    log_group_name       = local.log_group_name
    port                 = local.port
    image_repo           = local.image_repo
    healthcheck_endpoint = local.healthcheck_endpoint

    git_repo   = local.git_repo
    git_branch = local.git_branch

    ecs_cluster_name = local.ecs_cluster_outputs.ecs_cluster_name
    ecs_service_name = module.ecs_service.ecs_service_name

    fargate_cpu                = local.fargate_cpu
    fargate_memory             = local.fargate_memory
    fargate_ecs_execution_role = local.fargate_ecs_execution_role
    fargate_ecs_task_role      = local.fargate_ecs_task_role

    ssm_secret_path_prefix = local.ssm_secret_path_prefix
    app_secrets            = local.app_secrets
    app_environments       = local.app_environments

    codebuild_compute_type = local.codebuild_compute_type
    codebuild_image        = local.codebuild_image

    deploy_provider = var.deployment_strategy == "blue_green" ? "CodeDeployToECS" : "ECS"
    codedeploy_app  = var.deployment_strategy == "blue_green" ? "${local.task_name}-cd-app" : null
    codedeploy_dg   = var.deployment_strategy == "blue_green" ? "${local.task_name}-cd-dg" : null
  }
}
