module "ecs_cluster" {
  source             = "../../modules/ecs-cluster"
  ecs_cluster_config = local.ecs_cluster_config
}