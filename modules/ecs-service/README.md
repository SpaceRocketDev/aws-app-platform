# ECS Service Module

Terraform module that provisions an ECS Fargate service, task definition, IAM task role, security groups, CloudWatch logging, and optional blue green deployments using CodeDeploy.  
This module is designed to be consumed by higher level stacks that already provide networking, ALB routing, and CI CD orchestration.

## What This Module Provisions

This module provisions the following core components:

- ECS task definition rendered from a template driven container definition
- ECS service with either rolling or blue green deployment strategy
- IAM task role with optional policies for ECS Exec, Secrets Manager, and SQS
- KMS encrypted CloudWatch Logs group for application logs
- Security group for Fargate tasks with ALB ingress and unrestricted egress
- Optional CodeDeploy application and deployment group for blue green traffic shifting

This module **does not** create CI CD pipelines, ALB listeners, or target groups.  
Those are expected to be created by upstream modules or stacks.

> [!IMPORTANT]
> ### Application name must exist in base configuration
>
> This module expects the `app_name` to already exist in the shared base configuration.
>
> The provided `app_name` **must be present** in:
>
> - `path_prefix_map`
> - `ssm_secret_path_prefix_map`
>
> If the application name is missing, derived values such as the log group name or secret paths will resolve to `null`, which will cause Terraform plan or apply failures.

## Deployment Strategies

The module supports two deployment strategies via `ecs_service_config.deployment_strategy`:

- `rolling`  
  Uses native ECS rolling updates with `aws ecs update-service`.

- `blue_green`  
  Uses CodeDeploy with:
  - Separate blue and green target groups
  - Production and test listeners
  - Automatic rollback on deployment failure

The service configuration, load balancer wiring, and CodeDeploy resources are conditionally created based on this value.

## Inputs

This module is configured using a single object input.

### `ecs_service_config` schema

| Name | Description | Type | Required |
|-----|-------------|------|----------|
| account_id | AWS account id | string | yes |
| project | Project name used for naming and tags | string | yes |
| env | Environment name (dev, prod, etc.) | string | yes |
| region | AWS region | string | yes |
| app_name | Logical application name | string | yes |
| app_names | List of valid application names from base | list(string) | yes |
| task_name | Name prefix used across ECS resources | string | yes |
| app_image | Full ECR image reference | string | yes |
| app_port | Container port exposed by the app | number | yes |
| app_count | Desired task count | number | yes |
| app_environments | ECS environment variables | list(object) | yes |
| app_secrets | ECS secrets from SSM | list(object) | yes |
| fargate_cpu | CPU units for the task | number | yes |
| fargate_memory | Memory in MiB for the task | number | yes |
| fargate_subnets | Subnets for task networking | list(any) | yes |
| ecs_cluster_id | ECS cluster id | string | yes |
| ecs_cluster_name | ECS cluster name | string | yes |
| ecs_execution_role | Execution role ARN | string | yes |
| vpc_id | VPC id | string | yes |
| alb_sg_id | ALB security group id | string | yes |
| tg_arn | Target group ARN for rolling deployments | string | yes |
| deployment_strategy | `rolling` or `blue_green` | string | yes |
| blue_tg_arn | Blue target group ARN | string | conditional |
| green_tg_arn | Green target group ARN | string | conditional |
| prod_listener_arn | ALB production listener ARN | string | conditional |
| test_listener_arn | ALB test listener ARN | string | conditional |
| log_group_name | CloudWatch Logs group name | string | yes |
| runtime_platform | CPU architecture (`ARM64` or `X86_64`) | string | yes |
| common_tags | Resource tags | map(string) | no |

## Outputs

This module exposes focused outputs intended for CI CD and downstream automation.

| Name | Description |
|------|-------------|
| ecs_service_name | ECS service name created by this module |
| task_name | Task and service name prefix |
| ecs_task_role_name | IAM role name assumed by the ECS task |
| ecs_task_definition_arn | ARN of the ECS task definition |
| ecs_task_definition_family | Task definition family |
| ecs_task_definition_revision | Task definition revision number |

## How It Fits In The Architecture

Typical consumption flow:

1. **Base module**
   - VPC
   - ALB
   - DNS
   - Shared naming and path maps

2. **ECS cluster module**
   - ECS cluster
   - Capacity providers
   - Execution roles

3. **Target group module**
   - ALB target groups
   - Listener rules

4. **ECS service module** (this module)
   - ECS service and task definition
   - IAM task role
   - Logging and security

5. **CodePipeline module**
   - Builds images
   - Registers new task definitions
   - Triggers ECS or CodeDeploy deployments

## Related Projects

- `modules/codepipeline`  
  Provisions CI CD pipelines that deploy into this ECS service.

- `modules/tg-fargate`  
  Provisions ALB target groups consumed by this service.

- `demo/03-apps/*`  
  Example stacks showing how this module is wired end to end.

> [!TIP]
> #### Use SpaceRocket.Dev Terraform Reference Architectures
>
> This module is part of the SpaceRocket.Dev AWS reference architecture.
> The code stays open source. The execution, context, and guidance are delivered through hands on consulting.
>
> <a href="https://spacerocket.dev">
> <img alt="Request Quote" src="https://img.shields.io/badge/request%20quote-success.svg?style=for-the-badge"/>
> </a>
