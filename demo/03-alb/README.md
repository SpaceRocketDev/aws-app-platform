![banner](../../docs/imgs/banner.png)

# 04-alb

This demo provisions a **production ready public Application Load Balancer (ALB)** with secure defaults for HTTPS ingress, DNS aliases, logging, and basic health and reliability alarms.

It is designed to sit on top of:

- `01-base` for shared identity, naming, and tags
- `02-network` for VPC and public subnets
- `03-sns` for the alarms topic used by CloudWatch

Apply those modules first.

## What this module provides

This demo creates and configures:

- An internet facing ALB (dualstack IPv4/IPv6)
- HTTP (80) to HTTPS (443) redirect
- HTTPS listener with a fixed default 403 response (deny by default)
- Security group ingress limited to `allowed_ips` (and optional NAT gateway EIP allow rules)
- Route53 alias records for the root domain and per app subdomains derived from `app_names`
- ALB access logs S3 bucket (AES256) plus an optional server access logs target bucket (KMS)
- CloudWatch alarms for ALB and target 5xx responses, delivered to SNS

## Inputs and remote state dependencies

This module consumes three remote state outputs:

- `base` from `01-base`
- `network` from `02-network`
- `sns` from `02-sns`

At minimum you must provide:

- `state_bucket`, `base_state_key`, `network_state_key`, `sns_state_key`
- `aws_region`
- `base_domain`
- `cert_arn`
- `allowed_ips`
- `app_names`

## Usage

### Backend configuration

Example `backend.hcl`:

```hcl
bucket = "terraform-demo-state-example-123456789"
key    = "terraform/state/alb.tfstate"
region = "us-east-1"
dynamodb_table = "terraform-state-locks-example"
````

### Example tfvars

```hcl
aws_region       = "us-east-1"
state_bucket     = "terraform-demo-state-example-123456789"
base_state_key   = "terraform/state/base.tfstate"
network_state_key = "terraform/state/network.tfstate"
sns_state_key    = "terraform/state/sns.tfstate"

base_domain  = "demo.spacerocket.dev"
cert_arn     = "arn:aws:acm:us-east-1:123456789012:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

allowed_ips = ["104.193.171.254"]
app_names   = ["", "prom", "graf", "app1"]
```

### Import remote state

**data.tf**:

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

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket       = var.state_bucket
    key          = var.network_state_key
    region       = var.aws_region
    use_lockfile = true
  }
}

data "terraform_remote_state" "sns" {
  backend = "s3"
  config = {
    bucket       = var.state_bucket
    key          = var.sns_state_key
    region       = var.aws_region
    use_lockfile = true
  }
}
```

### Apply

```bash
terraform init -backend-config=backend.hcl
terraform apply -var-file="terraform.tfvars"
```

## Notes

* `allowed_ips` accepts either CIDRs or plain IPv4 addresses. Plain IPs are normalized to `/32` for security group rules.
* DNS aliases are generated from `app_names`. Use an empty string (`""`) to represent the root domain.
* This demo uses a strict default action on the HTTPS listener (`403`) so no app traffic is routed until downstream ECS services attach listener rules and target groups.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.19.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm_certs"></a> [acm\_certs](#module\_acm\_certs) | ../../modules/acm | n/a |
| <a name="module_alb"></a> [alb](#module\_alb) | ../../modules/alb | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.network](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.sns](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_cert_arn"></a> [additional\_cert\_arn](#input\_additional\_cert\_arn) | Additional ACM certificate ARN reserved for future use (not currently passed into the ALB module configuration). | `string` | `""` | no |
| <a name="input_alb_config"></a> [alb\_config](#input\_alb\_config) | n/a | <pre>object({<br/>    account_id                = string<br/>    env                       = string<br/>    project                   = string<br/>    name_prefix               = string<br/>    aws_region                = string<br/>    vpc                       = any<br/>    lb_subnets                = list(any)<br/>    lb_sg                     = any<br/>    lb_ssl_policy             = string<br/>    main_domain               = string<br/>    additional_domains        = list(string)<br/>    logs_enabled              = bool<br/>    logs_prefix               = string<br/>    logs_bucket               = string<br/>    logs_expiration           = number<br/>    logs_bucket_force_destroy = bool<br/>    main_cert_arn             = string<br/>    create_aliases = list(object({<br/>      name = string<br/>      zone = string<br/>    }))<br/>    alarm_sns_topic_name = string<br/>    common_tags          = map(string)<br/>    alb_5xx_threshold    = optional(number, 20)<br/>    target_5xx_threshold = optional(number, 20)<br/>  })</pre> | <pre>{<br/>  "account_id": "",<br/>  "additional_domains": [],<br/>  "alarm_sns_topic_name": "default-ecs-dev-alerts",<br/>  "alb_5xx_threshold": 20,<br/>  "aws_region": "us-east-1",<br/>  "common_tags": {<br/>    "Env": "dev",<br/>    "ManagedBy": "terraform",<br/>    "Project": "default"<br/>  },<br/>  "create_aliases": [],<br/>  "env": "dev",<br/>  "lb_sg": null,<br/>  "lb_ssl_policy": "ELBSecurityPolicy-TLS13-1-3-FIPS-2023-04",<br/>  "lb_subnets": [],<br/>  "logs_bucket": "default-dev-ecs-alb-logs",<br/>  "logs_bucket_force_destroy": false,<br/>  "logs_enabled": true,<br/>  "logs_expiration": 90,<br/>  "logs_prefix": "dev",<br/>  "main_cert_arn": "",<br/>  "main_domain": "example.com",<br/>  "name_prefix": "myapp-dev",<br/>  "project": "default",<br/>  "target_5xx_threshold": 20,<br/>  "vpc": null<br/>}</pre> | no |
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | IPv4 addresses allowed to reach the public ALB. Values can be plain IPs (x.x.x.x) or CIDRs. Plain IPs are normalized to /32 for security group rules. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_app_names"></a> [app\_names](#input\_app\_names) | List of application subdomain prefixes used to generate fqdn\_map, Route53 alias records, and per-app SSM/path prefixes. Use an empty string to represent the root domain. | `list(string)` | <pre>[<br/>  "",<br/>  "app"<br/>]</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy into. Used for provider configuration, regional service ARNs, and region-specific resources (for example, ELB log delivery account mapping). | `string` | `"us-east-1"` | no |
| <a name="input_base_domain"></a> [base\_domain](#input\_base\_domain) | Base DNS domain hosted in Route53. Used to generate per-app FQDNs (for example, app.base\_domain and base\_domain) and create ALB alias records. | `string` | `"example.com"` | no |
| <a name="input_base_state_key"></a> [base\_state\_key](#input\_base\_state\_key) | State key for the base stack | `string` | n/a | yes |
| <a name="input_cert_arn"></a> [cert\_arn](#input\_cert\_arn) | ACM certificate ARN used by the ALB HTTPS listener as the primary TLS certificate (passed as main\_cert\_arn). | `string` | `""` | no |
| <a name="input_lock_table_name"></a> [lock\_table\_name](#input\_lock\_table\_name) | DynamoDB table used for Terraform state locking | `string` | n/a | yes |
| <a name="input_network_state_key"></a> [network\_state\_key](#input\_network\_state\_key) | State key for the network stack | `string` | n/a | yes |
| <a name="input_sns_state_key"></a> [sns\_state\_key](#input\_sns\_state\_key) | State key for the sns stack | `string` | n/a | yes |
| <a name="input_state_bucket"></a> [state\_bucket](#input\_state\_bucket) | S3 bucket storing the base stack Terraform state | `string` | n/a | yes |

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