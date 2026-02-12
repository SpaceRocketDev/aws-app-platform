locals {
  deployment_strategy = var.deployment_strategy
}

locals {
  ecs_service_config = {
    account_id = local.account_id
    project    = local.base.project
    env        = local.base.env
    region     = local.region

    app_count = 1
    app_name  = local.app_name
    app_names = local.base.app_names

    app_image = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.image_repo}:${var.image_tag}"
    app_port  = var.port

    app_environments = [
      { name = "MODE_TYPE", value = "app" },
      { name = "AWS_DEFAULT_REGION", value = local.region },
    ]
    app_secrets = local.app_secrets

    assign_public_ip = false

    ecs_cluster_id     = local.ecs_cluster_outputs.ecs_cluster_id
    ecs_cluster_name   = local.ecs_cluster_outputs.ecs_cluster_name
    ecs_execution_role = local.ecs_cluster_outputs.ecs_execution_role_arn

    fargate_cpu     = var.fargate_cpu
    fargate_memory  = var.fargate_memory
    fargate_subnets = local.fargate_subnets

    healthcheck_endpoint     = var.healthcheck_endpoint
    healthcheck_interval     = 10
    healthcheck_retries      = 5
    healthcheck_start_period = 60
    healthcheck_timeout      = 10

    log_group_name = local.log_group_name

    path_prefix_map            = local.base.path_prefix_map
    ssm_secret_path_prefix_map = local.base.ssm_secret_path_prefix_map

    task_name   = local.task_name
    name_prefix = local.base.name_prefix
    common_tags = local.base.common_tags
    vpc_id      = local.network.vpc.id

    tg_arn = module.target_group.tg_arn

    deployment_strategy = local.deployment_strategy

    blue_tg_arn  = try(module.target_group.tg_arn, "")
    blue_tg_name = try(module.target_group.tg_name, "")

    green_tg_arn  = try(module.target_group_green[0].tg_arn, "")
    green_tg_name = try(module.target_group_green[0].tg_name, "")

    prod_listener_arn = local.listener_443_arn
    test_listener_arn = local.deployment_strategy == "blue_green" ? aws_lb_listener.test_8080.arn : null

    alb_sg_id = local.alb_sg_id

    runtime_platform = "ARM64"
  }
}
