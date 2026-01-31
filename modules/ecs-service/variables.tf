variable "ecs_service_config" {
  type = object({
    account_id = optional(string, "")

    app_count = optional(number, 1)

    app_environments = optional(
      list(object({
        name  = string
        value = string
      })),
      []
    )

    app_image = optional(
      string,
      "123456789012.dkr.ecr.us-east-1.amazonaws.com/app:latest"
    )

    app_name  = optional(string, "my_app")
    app_names = optional(list(string), [])

    app_port = optional(number, 8080)

    app_secrets = optional(
      list(object({
        name      = string
        valueFrom = string
      })),
      []
    )

    assign_public_ip = optional(bool, true)

    env = optional(string, "dev")

    ecs_cluster_id     = optional(string, "")
    ecs_cluster_name   = optional(string, "")
    ecs_execution_role = optional(string, "")

    fargate_cpu    = optional(number, 256)
    fargate_memory = optional(number, 512)

    fargate_subnets = optional(list(any), [])

    healthcheck_endpoint     = optional(string, "/health")
    healthcheck_interval     = optional(number, 30)
    healthcheck_retries      = optional(number, 3)
    healthcheck_start_period = optional(number, 60)
    healthcheck_timeout      = optional(number, 5)

    log_group_name = optional(string, "/ecs/app")

    path_prefix_map            = optional(map(string), {})
    ssm_secret_path_prefix_map = optional(map(string), {})

    project = optional(string, "default")
    region  = optional(string, "")
    runtime_platform = optional(string, "")

    task_name = optional(string, "app")

    tg_arn = optional(string, "")

    name_prefix = optional(string, "")
    common_tags = optional(map(string), {})
    vpc_id      = optional(string, "")

    deployment_strategy = optional(string, "rolling")

    # blue / green only
    blue_tg_arn       = optional(string, "")
    blue_tg_name      = optional(string, "")
    green_tg_arn      = optional(string, "")
    green_tg_name     = optional(string, "")
    prod_listener_arn = optional(string, "")
    test_listener_arn = optional(string, "")
    alb_sg_id         = optional(string, "")
  })
}
