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

