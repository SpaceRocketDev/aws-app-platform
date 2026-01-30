![banner](../../docs/imgs/banner.png)

# ECS Cluster Module Demo

**Module** to provision a production ready Amazon ECS cluster that serves as the shared compute foundation for application workloads.

This module builds on `01-base` and establishes a centralized ECS control plane using AWS Fargate. It creates the ECS cluster, capacity providers, execution and task IAM roles, and baseline permissions required to run containerized services securely and consistently. It is designed to be consumed by downstream modules that deploy ECS services, CI CD pipelines, and ALB routing rules.

## What This Module Provisions

This module provisions the following resources:

- An Amazon ECS cluster with Container Insights enabled.
- Fargate capacity provider configuration with a default strategy.
- An ECS execution role used by ECS to pull images, write logs, and access SSM and Secrets Manager.
- An ECS task role intended for application runtime permissions.
- IAM policies and attachments for SSM Parameter Store access under `ssm_secret_path_prefixes`.
- Shared outputs intended for consumption by downstream ECS service and application modules.

## Prerequisites

- `01-base` applied and available via Terraform remote state.
- Terraform state S3 bucket.
- AWS credentials with permissions to create ECS and IAM resources.

## Usage

### Backend Configuration

Configure Terraform backend state file:

**backend.hcl**
```hcl
bucket         = "terraform-demo-state-dce2cf761e97"
key            = "terraform/state/ecs-cluster.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-locks"
````

### Example tfvars

**terraform.tfvars**

```hcl
state_bucket     = "terraform-demo-state-dce2cf761e97"
base_state_key   = "terraform/state/base.tfstate"
lock_table_name  = "terraform-state-locks"
aws_region       = "us-east-1"
```

### Import Base Remote State

This module consumes outputs from `01-base`.

**data.tf**

```hcl
data "terraform_remote_state" "base" {
  backend = "s3"

  config = {
    bucket       = var.state_bucket
    key          = var.base_state_key
    region       = var.aws_region
    use_lockfile = true
  }
}
```

### Map base into ECS cluster config

The demo derives the AWS account ID at runtime and combines it with `base` outputs to build `ecs_cluster_config`.

**identity.tf**

```hcl
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}
```

**locals.tf**

```hcl
locals {
  base = data.terraform_remote_state.base.outputs.base

  ecs_cluster_config = {
    account_id              = local.account_id
    name_prefix             = local.base.name_prefix
    project                 = local.base.project
    env                     = local.base.env
    aws_region              = local.base.aws_region
    ssm_secret_path_prefixes = local.base.ssm_secret_path_prefixes

    # module inputs
    ecs_execution_role_arn = ""
    cluster_name_override  = ""
  }
}
```

### Apply

**ecs-cluster.tf**

```hcl
module "ecs_cluster" {
  source           = "../../modules/ecs-cluster"
  ecs_cluster_config = local.ecs_cluster_config
}
```

```bash
terraform init -backend-config=backend.hcl
terraform apply -var-file="terraform.tfvars"
```

## Notes

> [!IMPORTANT]
> In SpaceRocket.Dev demos and examples, this module relies on remote state from `01-base`.
> Ensure the base stack is applied successfully before applying this module.
>
> This demo derives the AWS account ID at runtime using `data.aws_caller_identity.current.account_id`.
> For production environments, prefer an explicitly managed mapping for account specific values that influence security policy, ARNs, or trust boundaries.


## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.30.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | ../../modules/ecs-cluster | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | n/a | yes |
| <a name="input_base_state_key"></a> [base\_state\_key](#input\_base\_state\_key) | State key for the base stack | `string` | n/a | yes |
| <a name="input_lock_table_name"></a> [lock\_table\_name](#input\_lock\_table\_name) | DynamoDB table used for Terraform state locking | `string` | n/a | yes |
| <a name="input_state_bucket"></a> [state\_bucket](#input\_state\_bucket) | S3 bucket storing the base stack Terraform state | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster_outputs"></a> [ecs\_cluster\_outputs](#output\_ecs\_cluster\_outputs) | All ecs\_cluster primitives as a single object |

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