locals {
  log_stream_prefix          = "${formatdate("2006-01-02", timestamp())}"
  account_id                 = var.codepipeline_config.account_id
  project                    = var.codepipeline_config.project
  environment                = var.codepipeline_config.env
  env                        = var.codepipeline_config.env
  app_name                   = var.codepipeline_config.app_name
  task_name                  = var.codepipeline_config.task_name
  log_group_name             = var.codepipeline_config.log_group_name
  region                     = var.codepipeline_config.region
  git_repo                   = var.codepipeline_config.git_repo
  git_branch                 = var.codepipeline_config.git_branch
  ecs_cluster_name           = var.codepipeline_config.ecs_cluster_name
  ecs_service_name           = var.codepipeline_config.ecs_service_name
  fargate_cpu                = var.codepipeline_config.fargate_cpu
  fargate_memory             = var.codepipeline_config.fargate_memory
  fargate_ecs_task_role      = var.codepipeline_config.fargate_ecs_task_role
  fargate_ecs_execution_role = var.codepipeline_config.fargate_ecs_execution_role
  image_repo                 = var.codepipeline_config.image_repo
  port                       = var.codepipeline_config.port
  ssm_secret_path_prefix     = var.codepipeline_config.ssm_secret_path_prefix
  app_secrets                = var.codepipeline_config.app_secrets
  app_environments           = var.codepipeline_config.app_environments
  healthcheck_endpoint       = var.codepipeline_config.healthcheck_endpoint
  common_tags = {
    project     = local.project
    environment = local.environment
  }
  codebuild_compute_type = var.codepipeline_config.codebuild_compute_type
  codebuild_image        = var.codepipeline_config.codebuild_image
  codebuild_type         = can(regex("aarch64", var.codepipeline_config.codebuild_image)) ? "ARM_CONTAINER" : "LINUX_CONTAINER"

  # new
  deploy_provider = var.codepipeline_config.deploy_provider
  codedeploy_app  = try(var.codepipeline_config.codedeploy_app, null)
  codedeploy_dg   = try(var.codepipeline_config.codedeploy_dg, null)
}

# If a template exists, render it and use it. Otherwise fall back to the inline default.
locals {
  buildspec_build = try(file("${path.module}/templates/buildspec-build.yml.tp"), null)
}
