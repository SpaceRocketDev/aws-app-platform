![banner](../../docs/imgs/banner.png)

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


## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.ecs_app_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_iam_policy.ecs_exec_secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ecs_execution_ssm_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm_params_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecs_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_exec_secretsmanager_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_execution_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_execution_ssm_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_params_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.ecs_execution_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ecs_cluster_config"></a> [ecs\_cluster\_config](#input\_ecs\_cluster\_config) | Composite config for ECS cluster naming, account and region context, and secret path prefixes used for execution-role SSM access policies. | <pre>object({<br/>    env                      = string<br/>    account_id               = string<br/>    aws_region               = string<br/>    project                  = string<br/>    name_prefix              = string<br/>    ssm_secret_path_prefixes = list(string)<br/>    cluster_name_override    = string<br/>  })</pre> | <pre>{<br/>  "account_id": "000000000000",<br/>  "aws_region": "NOTSET",<br/>  "cluster_name_override": "",<br/>  "env": "dev",<br/>  "name_prefix": "default-dev",<br/>  "project": "default",<br/>  "ssm_secret_path_prefixes": [<br/>    "/default/"<br/>  ]<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | n/a |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | n/a |
| <a name="output_ecs_execution_role_arn"></a> [ecs\_execution\_role\_arn](#output\_ecs\_execution\_role\_arn) | n/a |
| <a name="output_ecs_task_role_arn"></a> [ecs\_task\_role\_arn](#output\_ecs\_task\_role\_arn) | n/a |
| <a name="output_ecs_task_role_name"></a> [ecs\_task\_role\_name](#output\_ecs\_task\_role\_name) | n/a |

---

> [!TIP]
> #### Use SpaceRocket.Dev Open Source Terraform Modules for AWS
>
> Use SpaceRocket.Dev’s ready to use Terraform modules for AWS to get up and running fast, without sacrificing security, ownership, or clarity.
>
> ✅ Side by side implementation of this module in your AWS account with your team.<br/>
> ✅ Your team owns the code and the outcome.<br/>
> ✅ 100% Open Source Terraform with paid, hands on consultancy.<br/>
>
> <a href="https://spacerocket.dev"><img alt="Request Quote" src="https://img.shields.io/badge/request%20quote-success.svg?style=for-the-badge"/></a>
>
> <details>
> <summary>📚 <strong>Learn More</strong></summary>
>
> <br/>
>
> SpaceRocket.Dev is a solo DevSecOps consultancy based in San Francisco, CA; focused on helping teams build secure, compliant, production ready AWS platforms using Terraform as the source of truth.
>
> *Your team ships faster, with fewer surprises.*
>
> We combine open source Terraform modules with direct, senior level guidance. The code stays public and reusable. The expertise, context, and execution are delivered through consulting.
>
> #### Foundation for Production
> - **Reference Architecture.** A complete AWS foundation built using Terraform, designed to scale with your product and team.
> - **CI/CD Strategy.** Proven delivery patterns using AWS native tooling, focused on repeatability, auditability, and compliance readiness.
> - **Observability.** Practical visibility into infrastructure and workloads so issues are detected early and teams operate with confidence.
> - **Security Baseline.** Secure by default configurations aligned with SOC 2, FedRAMP, NIST 800 53, and Zero Trust principles.
> - **GitOps Workflow.** Infrastructure changes managed through pull requests, reviews, and approvals so everything stays in version control.
>
> <a href="https://spacerocket.dev"><img alt="Request Quote" src="https://img.shields.io/badge/request%20quote-success.svg?style=for-the-badge"/></a>
>
> #### Ongoing Operational Support
> - **Training.** Clear explanations of how and why the system is built so your team can run it independently.
> - **Direct Support.** Slack based access to the engineer who implemented the platform.
> - **Troubleshooting.** Fast help diagnosing and resolving real world issues.
> - **Code Reviews.** Practical feedback on Terraform, CI/CD, and security changes as your platform evolves.
> - **Bug Fixes.** Hands on remediation when improvements or fixes are needed.
> - **Migration Support.** Guidance and execution help when moving from legacy setups to Terraform driven infrastructure.
> - **Weekly Working Sessions.** Optional live sessions to review progress, answer questions, and plan next steps.
>
> <a href="https://spacerocket.dev"><img alt="Request Quote" src="https://img.shields.io/badge/request%20quote-success.svg?style=for-the-badge"/></a>
>
> </details>