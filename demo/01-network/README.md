![banner](../../docs/imgs/banner.png)

# Network Module Demo

This demo provisions a **production ready AWS VPC networking layer** intended to be reused by downstream infrastructure stacks.

The network module is responsible only for **network primitives and connectivity**. It deliberately avoids application ingress, load balancers, certificates, DNS, and alerting concerns, which are handled by higher level modules.

This module provides a consistent, IPv6 enabled VPC layout with controlled egress, private service access, and opinionated defaults suitable for compliant, production environments.

It is designed to serve as the foundational network layer for ECS, EKS, RDS, and other AWS native workloads that require a repeatable, auditable networking baseline.

## What This Module Provisions

This demo provisions the following network resources:

- A dedicated AWS VPC with DNS support and an automatically assigned IPv6 CIDR block
- Public and private subnets spread across a configurable number of Availability Zones
- Internet Gateway and routing for public subnets
- Configurable NAT Gateway strategy for private subnet egress (`none`, `one`, or `all`)
- Elastic IPs for NAT Gateways when enabled
- VPC Flow Logs delivered to CloudWatch Logs using a dedicated KMS key and least privilege IAM role
- Interface VPC Endpoints for:
  - AWS Systems Manager
  - AWS Secrets Manager
- Private DNS enabled for all interface endpoints
- A dedicated security group for VPC endpoints
- Shared network outputs intended for consumption by downstream modules

## Prerequisites

- Terraform state S3 bucket, for example `terraform-demo-state-example-123456789`
  - S3 bucket names are global and must be unique
- Terraform state lock DynamoDB table, for example `terraform-state-locks-example`
- AWS account credentials configured for the target account

## Usage

### Backend Configuration

Configure the Terraform backend for remote state:

**backend.hcl**
```hcl
bucket         = "terraform-demo-state-example-123456789"
key            = "terraform/state/network.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-locks-example"
````

### Required Variables

The following variables must be provided:

* `env`
* `org`
* `project`
* `aws_region`
* `natgw_count`

### Example tfvars File

**terraform.tfvars**

```hcl
env          = "dev"
org          = "spr"
project      = "demo-dvoc"
aws_region   = "us-east-1"
natgw_count  = "one"
```

> [!IMPORTANT]
> This demo derives the AWS account ID at runtime using `data.aws_caller_identity.current.account_id`.
> This keeps the example portable across accounts without requiring an explicit `account_id` variable.
>
> For production environments, we recommend using a static, explicitly managed mapping for any account specific values that influence security policy, ARNs, or trust boundaries. This avoids accidental drift when running the same code across multiple accounts.

**identity.tf**

```hcl
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}
```

> [!IMPORTANT]
> In SpaceRocket.Dev demos, modules may not be pinned to specific versions to reduce documentation drift.
> For real environments, always pin module versions explicitly to maintain infrastructure stability.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](#module\_network) | ../../modules/network | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_email"></a> [admin\_email](#input\_admin\_email) | Email address subscribed to the SNS alerts topic for CloudWatch alarms (ALB 5xx and target 5xx). | `string` | `"admin@example.com"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy into. Used for provider configuration, regional service ARNs, and region-specific resources (for example, ELB log delivery account mapping). | `string` | `"us-east-1"` | no |
| <a name="input_env"></a> [env](#input\_env) | Deployment environment identifier (for example: dev, staging, prod). Used in name\_prefix, tags, log prefixes, and DNS/SSM path construction. | `string` | `"dev"` | no |
| <a name="input_natgw_count"></a> [natgw\_count](#input\_natgw\_count) | NAT Gateway strategy for the VPC. Supported values: "none" (0 NAT gateways), "one" (single NAT gateway), "all" (one NAT gateway per AZ). Affects NAT EIPs that are also allow-listed on the ALB security group. | `string` | `"one"` | no |
| <a name="input_network_config"></a> [network\_config](#input\_network\_config) | n/a | <pre>object({<br/>    base_domain         = string<br/>    account_id          = string<br/>    env                 = string<br/>    project             = string<br/>    aws_region          = string<br/>    az_num              = number<br/>    vpc_ip_block        = string<br/>    subnet_cidr_private = string<br/>    subnet_cidr_public  = string<br/>    new_bits_private    = number<br/>    new_bits_public     = number<br/>    natgw_count         = string<br/>    public_ips          = map(string)<br/>    public_ips_v6       = map(string)<br/>    app_ports           = list(number)<br/>    common_tags         = map(string)<br/>  })</pre> | <pre>{<br/>  "account_id": "",<br/>  "app_ports": [<br/>    80,<br/>    443<br/>  ],<br/>  "aws_region": "us-east-1",<br/>  "az_num": 3,<br/>  "base_domain": "example.com",<br/>  "common_tags": {<br/>    "Env": "dev",<br/>    "ManagedBy": "terraform",<br/>    "Project": "default"<br/>  },<br/>  "env": "dev",<br/>  "natgw_count": "none",<br/>  "new_bits_private": 2,<br/>  "new_bits_public": 2,<br/>  "project": "default",<br/>  "public_ips": {<br/>    "0.0.0.0/0": "Open"<br/>  },<br/>  "public_ips_v6": {<br/>    "::/0": "Open"<br/>  },<br/>  "subnet_cidr_private": "172.27.72.0/24",<br/>  "subnet_cidr_public": "172.27.73.0/24",<br/>  "vpc_ip_block": "172.27.72.0/22"<br/>}</pre> | no |
| <a name="input_org"></a> [org](#input\_org) | Organization or tenant identifier used to build name\_prefix and hierarchical paths (org/project/env) for SSM and routing. | `string` | `"example"` | no |
| <a name="input_project"></a> [project](#input\_project) | Project identifier used in name\_prefix, tags, logs bucket naming, and routing/SSM path construction. | `string` | `"demo"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network"></a> [network](#output\_network) | All base primitives as a single object for downstream stacks via remote state. |
| <a name="output_network2"></a> [network2](#output\_network2) | Network primitives for downstream stacks via remote state. |

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