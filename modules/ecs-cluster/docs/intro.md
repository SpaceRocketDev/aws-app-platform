# ECS Cluster Module

This module provisions a production ready **Amazon ECS cluster** that serves as the shared compute control plane for ECS/Fargate workloads.

It creates an ECS cluster with **Container Insights** enabled, configures the cluster to use the **FARGATE** capacity provider by default, and establishes baseline IAM roles used by ECS tasks:

- **Execution role**: used by ECS to pull images, publish logs, and retrieve runtime configuration (SSM parameters and Secrets Manager secrets).
- **Task role**: assumed by your application containers at runtime (no permissions are attached by default).

This module is designed to be consumed by downstream modules that deploy ECS services, target groups, CI/CD pipelines, and ALB routing.

## What this module provisions

- `aws_ecs_cluster` with `containerInsights = enabled`
- `aws_ecs_cluster_capacity_providers` with a default strategy using `FARGATE`
- ECS execution role:
  - AWS managed `AmazonECSTaskExecutionRolePolicy`
  - Optional SSM Parameter Store read access under `ecs_cluster_config.ssm_secret_path_prefixes`
  - Secrets Manager read access (scoped to your account and region)
  - KMS decrypt permission constrained to Secrets Manager via `kms:ViaService`
- ECS task role for application runtime permissions (permission attachments handled downstream)

## Inputs

This module uses a single composite input: `ecs_cluster_config`.

At minimum, you should provide:

- `env`, `project`, `name_prefix`
- `account_id`, `aws_region`
- `ssm_secret_path_prefixes` for execution role SSM access policies

You may optionally set `cluster_name_override` to force an explicit cluster name.

## Usage

### Example

```hcl
module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  ecs_cluster_config = {
    env                    = local.base.env
    project                = local.base.project
    name_prefix            = local.base.name_prefix
    account_id             = local.account_id
    aws_region             = local.base.aws_region
    ssm_secret_path_prefixes = local.base.ssm_secret_path_prefixes

    # Optional
    cluster_name_override  = ""
  }
}
````

## Outputs

This module exports core ECS primitives for downstream stacks:

* `ecs_cluster_id`
* `ecs_cluster_name`
* `ecs_execution_role_arn`
* `ecs_task_role_arn`
* `ecs_task_role_name`

## Notes

> [!IMPORTANT]
> This module does **not** create networking primitives like a VPC, subnets, or security groups. ECS/Fargate services created downstream must be attached to an existing VPC and subnets (typically provided by your network baseline module).

> [!TIP]
> Keep the execution role permissions minimal and push application specific access (databases, queues, KMS, service APIs) onto the **task role** in downstream service modules.

