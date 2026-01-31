# module "rmb_auto_scaling_fargate_predefined_cpu_ram" {
#   source                     = "./modules/autoscaling-fargate-predefined-cpu-ram"
#   account_id                 = local.account_id
#   env                        = var.env
#   project                    = var.project
#   region                     = var.region
#   auto_scale_min_capacity    = 0
#   auto_scale_max_capacity    = 3
#   desired_memory_utilization = 80
#   desired_cpu_utilization    = 80
#   ecs_cluster_name           = module.ecs_cluster.ecs_cluster_name
#   ecs_service_name           = module.rmb.ecs_service_name
#   app_name                   = module.rmb.app_name
# }