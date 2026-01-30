# 02-sns

This **module** provisions the shared **SNS alerts topic** used by CloudWatch alarms across the stack.
It consumes the `base` object from `01-base` via remote state to inherit identity, naming, and tags.

Apply this module after `01-base` and before any modules that need an alarm topic ARN.

## What this module provides

This module outputs:

- `topic_arn`
- `topic_name`

These outputs are intended to be consumed by downstream modules (for example ALB, ECS services, RDS) that create CloudWatch alarms.

## Usage

### Backend configuration

Example `backend.hcl`:

```hcl
bucket         = "terraform-demo-state-xxxx"
key            = "terraform/state/sns.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-locks"
````

### Apply 02-sns

Example `terraform.tfvars`:

```hcl
state_bucket  = "terraform-demo-state-xxxx"
state_key    = "terraform/state/01-base.tfstate"
lock_table_name   = "terraform-state-locks"
aws_region        = "us-east-1"

# Email address subscribed to the alerts topic
admin_email = "admin@example.com"
```

```bash
terraform init -backend-config=backend.hcl
terraform apply -var-file="terraform.tfvars"
```

## Consuming base outputs

This module reads `01-base` remote state and maps the exported object into locals.

### Read remote state

```hcl
data "terraform_remote_state" "base" {
  backend = "s3"

  config = {
    bucket       = var.state_bucket 
    key          = var.state_key
    region       = var.aws_region
    use_lockfile = true
  }
}
```

### Map into locals

```hcl
locals {
  base        = data.terraform_remote_state.base.outputs.base
  name_prefix = local.base.name_prefix
  common_tags = local.base.common_tags

  topic_name  = "${local.base.name_prefix}-ecs-alerts"
}
```

## Consuming SNS outputs in downstream modules

Downstream modules should import the SNS topic ARN via remote state and pass it into modules that create alarms.

### Read remote state

```hcl
data "terraform_remote_state" "sns" {
  backend = "s3"

  config = {
    bucket         = "terraform-demo-state-xxxx"
    key            = "terraform/state/sns.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
  }
}
```

### Use in modules

```hcl
locals {
  sns_topic_arn = data.terraform_remote_state.sns.outputs.topic_arn
}

module "alb" {
  source = "../../modules/alb"

  alarm_sns_topic_arn = local.sns_topic_arn

  # alb-specific inputs
}
```

## Design notes

* SNS is separated so multiple modules can reuse one alerting destination
* Subscriptions are defined here (for example email), not in every consuming module
* The topic name is derived from `base.name_prefix` for consistency across environments
* Default encryption uses `alias/aws/sns`, but the module supports a custom `kms_key_arn`
