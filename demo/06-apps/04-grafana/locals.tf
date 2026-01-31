# Loads application secrets from SSM Parameter Store
data "aws_ssm_parameters_by_path" "all_app_secrets" {
  path            = local.ssm_secret_path_prefix
  recursive       = true
  with_decryption = true
}

locals {
  base                     = data.terraform_remote_state.base.outputs.base
  name_prefix              = local.base.name_prefix
  project                  = local.base.project
  env                      = local.base.env
  aws_region               = local.base.aws_region
  ssm_secret_path_prefixes = local.base.ssm_secret_path_prefixes
  common_tags              = local.base.common_tags
  app_names                = local.base.app_names
  fqdn_map                 = local.base.fqdn_map

  alb                  = data.terraform_remote_state.alb.outputs.alb
  alb_arn              = local.alb.alb_arn
  alb_listener_443_arn = local.alb.alb_listener_443_arn
  lb_ssl_policy        = local.alb.lb_ssl_policy
  cert_arn             = local.alb.cert_arn
  alb_arn_suffix       = local.alb.alb_arn_suffix
  alb_sg_id            = local.alb.alb_sg_id

  sns           = data.terraform_remote_state.sns.outputs.sns
  sns_topic_arn = local.sns.sns_topic_arn

  ecs_cluster                = data.terraform_remote_state.ecs_cluster.outputs.ecs_cluster
  ecs_cluster_outputs        = data.terraform_remote_state.ecs_cluster.outputs.ecs_cluster
  fargate_ecs_execution_role = local.ecs_cluster_outputs.ecs_execution_role_arn


  network = data.terraform_remote_state.network.outputs.network

  app_name = var.app_name

  app_secrets = [
    for path_prefix in local.names : {
      name      = basename(path_prefix)
      valueFrom = path_prefix
    }
  ]
  app_environments = []
  base_outputs     = data.terraform_remote_state.base.outputs.base
  path_prefix = lookup(
    local.base.path_prefix_map,
    var.app_name,
    null
  )
  codebuild_compute_type = var.codebuild_compute_type
  codebuild_image        = var.codebuild_image
  # ecs_cluster_outputs        = data.terraform_remote_state.ecs_cluster.outputs.ecs_cluster_outputs

  fargate_cpu = var.fargate_cpu

  fargate_ecs_task_role = module.ecs_service.ecs_task_role_name
  fargate_memory        = var.fargate_memory
  fargate_subnets       = local.network.private_subnet_ids
  git_branch            = var.git_branch
  git_repo              = var.git_repo
  healthcheck_endpoint  = var.healthcheck_endpoint
  image_repo            = var.image_repo
  listener_443_arn      = local.alb.alb_listener_443_arn
  log_group_name        = "${local.path_prefix}/ecs-service"
  names                 = data.aws_ssm_parameters_by_path.all_app_secrets.names
  port                  = var.port
  region                = local.aws_region
  root_domain           = lookup(local.fqdn_map, "root", null)

  ssm_secret_path_prefix = lookup(
    local.base_outputs.ssm_secret_path_prefix_map,
    var.app_name,
    null
  )
  task_name = "${local.name_prefix}-${local.app_name}"
  vpc_id    = local.network.vpc.id
}
