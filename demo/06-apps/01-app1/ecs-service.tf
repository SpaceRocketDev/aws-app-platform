module "ecs_service" {
  source             = "../../../modules/ecs-service"
  ecs_service_config = local.ecs_service_config

  depends_on = [
    module.target_group,
    module.target_group_green
  ]
}