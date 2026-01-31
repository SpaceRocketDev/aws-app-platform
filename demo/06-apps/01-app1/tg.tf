module "target_group" {
  source              = "../../../modules/tg-fargate"
  target_group_config = local.target_group_config
}

# Green target group only when blue_green
module "target_group_green" {
  source               = "../../../modules/tg-fargate"
  count                = var.deployment_strategy == "blue_green" ? 1 : 0
  target_group_config  = local.green_target_group_config
  create_listener_rule = false
}
