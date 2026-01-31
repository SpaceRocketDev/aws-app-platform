output "ecs_cluster" {
  description = "All ecs_cluster primitives as a single object"
  value = {
    ecs_execution_role_arn = module.ecs_cluster.ecs_execution_role_arn
    ecs_cluster_name       = module.ecs_cluster.ecs_cluster_name
    ecs_cluster_id         = module.ecs_cluster.ecs_cluster_id
    ecs_task_role_name     = module.ecs_cluster.ecs_task_role_name # new
    ecs_task_role_arn      = module.ecs_cluster.ecs_task_role_arn  # new
  }
}
