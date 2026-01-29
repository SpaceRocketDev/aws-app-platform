![banner](../../docs/imgs/banner.png)

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
base_state_bucket = "terraform-demo-state-xxxx"
base_state_key    = "terraform/state/01-base.tfstate"
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
    bucket         = var.base_state_bucket
    key            = var.base_state_key
    region         = var.aws_region
    dynamodb_table = var.lock_table_name
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

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.19.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sns_dev_alerts"></a> [sns\_dev\_alerts](#module\_sns\_dev\_alerts) | ../../modules/sns | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_email"></a> [admin\_email](#input\_admin\_email) | Email address subscribed to the SNS alerts topic for CloudWatch alarms (ALB 5xx and target 5xx). | `string` | `"admin@example.com"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | n/a | yes |
| <a name="input_base_state_bucket"></a> [base\_state\_bucket](#input\_base\_state\_bucket) | S3 bucket storing the base stack Terraform state | `string` | n/a | yes |
| <a name="input_base_state_key"></a> [base\_state\_key](#input\_base\_state\_key) | State key for the base stack | `string` | n/a | yes |
| <a name="input_lock_table_name"></a> [lock\_table\_name](#input\_lock\_table\_name) | DynamoDB table used for Terraform state locking | `string` | n/a | yes |
| <a name="input_sns_config"></a> [sns\_config](#input\_sns\_config) | n/a | <pre>object({<br/>    account_id = string<br/>    env        = string<br/>    project    = string<br/>    region     = string<br/>    topic_name = string<br/>    subscriptions = map(object({<br/>      protocol = string<br/>      endpoint = string<br/>    }))<br/>  })</pre> | <pre>{<br/>  "account_id": "",<br/>  "env": "dev",<br/>  "project": "default",<br/>  "region": "us-east-1",<br/>  "subscriptions": {<br/>    "admin": {<br/>      "endpoint": "admin@example.com",<br/>      "protocol": "email"<br/>    }<br/>  },<br/>  "topic_name": "default-ecs-dev-alerts"<br/>}</pre> | no |

## Outputs

No outputs.

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