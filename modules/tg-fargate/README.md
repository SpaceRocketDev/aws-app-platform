# Target Group Module

Terraform module that provisions an Application Load Balancer target group and optional listener rule for routing traffic to ECS Fargate services.

This module is designed to be consumed by downstream ECS service stacks. It encapsulates ALB target group configuration, health checks, listener rule creation, and CloudWatch alarms for target level HTTP 5xx errors. It supports both single target group (rolling deployments) and paired blue/green target groups when used with CodeDeploy.

## What This Module Provisions

- An ALB target group configured for ECS Fargate tasks.
- Optional HTTPS listener rule with host and path based routing.
- Health check configuration aligned with ECS container health endpoints.
- CloudWatch alarm for target level HTTP 5xx errors.
- Outputs consumed by `modules/ecs-service` for service attachment.

## Usage

### Example

```hcl
module "target_group" {
  source = "../../modules/tg-target"

  target_group_config = {
    account_id              = "123456789012"
    env                     = "prod"
    project                 = "space-rocket"
    name_prefix             = "space-rocket-prod"
    vpc_id                  = module.network.vpc.id

    tg_name                 = "app1-blue"
    tg_port                 = 9091
    tg_protocol             = "HTTP"
    deregistration_delay    = 60

    health_check_enabled    = true
    health_check_port       = 9091
    health_check_protocol   = "HTTP"
    health_check_path       = "/-/ready"
    health_check_matcher    = "200-301"
    health_check_interval   = 30
    health_check_timeout    = 5
    health_check_threshold  = 2
    health_check_unhealthy_threshold = 2

    listener_443_arn        = data.terraform_remote_state.base.outputs.alb_listener_443_arn
    priority                = 100
    host_headers            = ["app1.example.com"]

    alb_arn_suffix          = data.terraform_remote_state.base.outputs.alb_arn_suffix
    alarm_sns_topic_arn     = data.terraform_remote_state.base.outputs.sns_topic_arn

    common_tags = {
      Env       = "prod"
      Project   = "space-rocket"
      ManagedBy = "terraform"
    }
  }
}

````markdown
# Target Group Module

Terraform module that provisions an Application Load Balancer target group and optional listener rule for routing traffic to ECS Fargate services.

This module is designed to be consumed by downstream ECS service stacks. It encapsulates ALB target group configuration, health checks, listener rule creation, and CloudWatch alarms for target level HTTP 5xx errors. It supports both single target group (rolling deployments) and paired blue/green target groups when used with CodeDeploy.

## What This Module Provisions

- An ALB target group configured for ECS Fargate tasks.
- Optional HTTPS listener rule with host and path based routing.
- Health check configuration aligned with ECS container health endpoints.
- CloudWatch alarm for target level HTTP 5xx errors.
- Outputs consumed by `modules/ecs-service` for service attachment.

## Usage

### Example

```hcl
module "target_group" {
  source = "../../modules/tg-target"

  target_group_config = {
    account_id              = "123456789012"
    env                     = "prod"
    project                 = "space-rocket"
    name_prefix             = "space-rocket-prod"
    vpc_id                  = module.network.vpc.id

    tg_name                 = "app1-blue"
    tg_port                 = 9091
    tg_protocol             = "HTTP"
    deregistration_delay    = 60

    health_check_enabled    = true
    health_check_port       = 9091
    health_check_protocol   = "HTTP"
    health_check_path       = "/-/ready"
    health_check_matcher    = "200-301"
    health_check_interval   = 30
    health_check_timeout    = 5
    health_check_threshold  = 2
    health_check_unhealthy_threshold = 2

    listener_443_arn        = data.terraform_remote_state.base.outputs.alb_listener_443_arn
    priority                = 100
    host_headers            = ["app1.example.com"]

    alb_arn_suffix          = data.terraform_remote_state.base.outputs.alb_arn_suffix
    alarm_sns_topic_arn     = data.terraform_remote_state.base.outputs.sns_topic_arn

    common_tags = {
      Env       = "prod"
      Project   = "space-rocket"
      ManagedBy = "terraform"
    }
  }
}
````

## Inputs

This module is configured using a single object input: `target_group_config`.

| Name                | Description                                                                       | Type   | Default            | Required |
| ------------------- | --------------------------------------------------------------------------------- | ------ | ------------------ | -------- |
| target_group_config | Composite config for ALB target group, listener rules, health checks, and alarms. | object | see `variables.tf` | No       |

### target_group_config schema

| Field                            | Description                                       | Type         | Required |
| -------------------------------- | ------------------------------------------------- | ------------ | -------- |
| account_id                       | AWS account id                                    | string       | yes      |
| env                              | Environment name (dev, prod, etc.)                | string       | yes      |
| project                          | Project identifier used in names and tags         | string       | yes      |
| name_prefix                      | Name prefix used for resources                    | string       | yes      |
| vpc_id                           | VPC id where the target group is created          | string       | yes      |
| tg_name                          | Target group name                                 | string       | yes      |
| tg_port                          | Port exposed by the target group                  | number       | yes      |
| tg_protocol                      | Protocol used by the target group (HTTP or HTTPS) | string       | yes      |
| deregistration_delay             | Deregistration delay in seconds                   | number       | yes      |
| health_check_enabled             | Whether health checks are enabled                 | bool         | yes      |
| health_check_port                | Health check port                                 | number       | yes      |
| health_check_protocol            | Health check protocol                             | string       | yes      |
| health_check_path                | HTTP path used for health checks                  | string       | yes      |
| health_check_matcher             | Expected HTTP codes                               | string       | yes      |
| health_check_interval            | Health check interval in seconds                  | number       | yes      |
| health_check_timeout             | Health check timeout in seconds                   | number       | yes      |
| health_check_threshold           | Healthy threshold                                 | number       | yes      |
| health_check_unhealthy_threshold | Unhealthy threshold                               | number       | yes      |
| listener_443_arn                 | ALB HTTPS listener ARN                            | string       | yes      |
| priority                         | Listener rule priority                            | number       | yes      |
| host_headers                     | Host headers for routing rules                    | list(string) | yes      |
| alb_arn_suffix                   | ALB ARN suffix used for CloudWatch metrics        | string       | yes      |
| alarm_sns_topic_arn              | SNS topic ARN for alarms                          | string       | yes      |
| common_tags                      | Tags applied to resources                         | map(string)  | yes      |

> [!NOTE]
> Listener rule creation can be disabled by consumers that manage routing externally, such as when creating a secondary green target group for blue green deployments.

## Outputs

| Name              | Description                          |
| ----------------- | ------------------------------------ |
| tg_arn            | ARN of the target group.             |
| tg_name           | Name of the target group.            |
| listener_rule_arn | ARN of the listener rule if created. |

## Resources

| Name                                   | Type     | Description                                   |
| -------------------------------------- | -------- | --------------------------------------------- |
| aws_lb_target_group.this               | resource | ALB target group for ECS tasks.               |
| aws_lb_listener_rule.this              | resource | HTTPS listener rule for host or path routing. |
| aws_cloudwatch_metric_alarm.target_5xx | resource | Alarm for target HTTP 5xx errors.             |

## Notes

* This module is intentionally stateless and reusable across applications.
* Blue green deployments typically create two instances of this module with different target group names and priorities.
* Health check configuration should match the ECS container health endpoint exactly to avoid deployment failures.
* Alarm thresholds should align with the ALB module defaults for consistent alerting behavior.

## Related Projects

* `modules/ecs-service` attaches ECS services to the target group created by this module.
* `modules/alb` provides the load balancer and listeners consumed here.
* `modules/codepipeline` and CodeDeploy integrate with blue green target groups for controlled deployments.

