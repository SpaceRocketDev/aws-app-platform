![banner](../../docs/imgs/banner.png)

# Base Module Group Demo

**Module Group** to provision a production-ready AWS networking and application ingress foundation.

This Module Group provisions a fully configured AWS VPC, Application Load Balancer, ACM certificates, and alerting infrastructure. It is designed to serve as the foundational layer for compliant, internet-facing workloads, providing secure networking, HTTPS ingress, DNS aliasing, access logging, and operational alarms. Ideal for teams building ECS, EKS, or other AWS-native application platforms that require a repeatable, auditable, and production-grade infrastructure baseline.

## What This Module Provisions

This Module Group provisions the following resources:
- A fully configured AWS VPC with public and private subnets spanning multiple Availability Zones, including NAT gateway support.
- An internet-facing Application Load Balancer with HTTPS listeners, modern TLS security policies, access logging, and health checks.
- ACM certificate integration for primary and additional domains to enable TLS termination.
- Route53 alias records for application domains and subdomains.
- CloudWatch alarms and SNS topics for load balancer and target health alerting.
- Shared outputs intended for consumption by downstream ECS, EKS, or other AWS native application modules.

## Prerequisites
- Terraform state bucket, ex: `terraform-demo-state-example-123456789`. Note S3 buckets names are global, so make sure its unique. 
- Terraform state lock Dynamo DB table created, ex: `terraform-state-locks-example`
- Domain name with ACM certificate created.


## Usage

### Backend Configuration

Configure Terraform backend state file:
**backends.tf**
```hcl
bucket         = "terraform-demo-state-example-123456789"
key            = "terraform/state/network.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-locks-example"
```

### Custom Variables

These variables are required to be passed in:
- `admin_email`
- `base_domain`
- `env`
- `org`
- `project`
- `aws_region`
- `allowed_ips`
- `app_names`
- `natgw_count`
- `cert_arn`
- `additional_cert_arn`

#### Example .tfvars file:

**terraform.tfvars**
```hcl
admin_email         = "admin@spacerocket.dev"
base_domain         = "demo.spacerocket.dev"
env                 = "dev"
org                 = "example"
project             = "demo-proj" # keep limited to 9 characters
aws_region          = "us-east-1"
allowed_ips         = ["203.0.113.10"] # your IP or VPN address
app_names           = ["", "prom", "graf", "cwe", "hello"]
natgw_count         = "one"
cert_arn            = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
additional_cert_arn = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
```

> [!IMPORTANT]
> In SpaceRocket.Dev demos and examples, we use the `spacerocket.dev` domain for illustration purposes only.
> You must replace this with a domain that you own and control before applying any infrastructure.
>
> Using a domain you do not own can cause certificate validation failures, DNS errors, and unintended conflicts.
> Always configure Route53 zones, ACM certificates, and DNS records against your own domain in real environments.



```bash

```

> [!IMPORTANT]
> In SpaceRocket.Dev’s demos, we avoid pinning modules to specific versions to reduce the risk of documentation drifting from the most recent releases.
> However, for your own projects, we strongly recommend pinning each module to the exact version in use.
> This helps maintain infrastructure stability.
> We also suggest adopting a consistent process for managing and updating versions to prevent unexpected changes.

> [!IMPORTANT]
> This repository derives the AWS account ID at runtime using `data.aws_caller_identity.current.account_id`.
> We do this to keep the demo and examples portable across accounts without requiring `var.account_id`.
>
> For production, we recommend using a static, explicitly managed mapping for any account specific values that influence
> security policy, ARNs, or trust boundaries (for example, cross account IAM/KMS policies, allowlists, or organization
> guardrails). This avoids accidental drift when running the same code across multiple accounts and environments.

**identity.tf**
```tf
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.19.0 |

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
| <a name="input_additional_cert_arn"></a> [additional\_cert\_arn](#input\_additional\_cert\_arn) | Additional ACM certificate ARN reserved for future use (not currently passed into the ALB module configuration). | `string` | `""` | no |
| <a name="input_admin_email"></a> [admin\_email](#input\_admin\_email) | Email address subscribed to the SNS alerts topic for CloudWatch alarms (ALB 5xx and target 5xx). | `string` | `"admin@example.com"` | no |
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | IPv4 addresses allowed to reach the public ALB. Values can be plain IPs (x.x.x.x) or CIDRs. Plain IPs are normalized to /32 for security group rules. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_app_names"></a> [app\_names](#input\_app\_names) | List of application subdomain prefixes used to generate fqdn\_map, Route53 alias records, and per-app SSM/path prefixes. Use an empty string to represent the root domain. | `list(string)` | <pre>[<br/>  "",<br/>  "app"<br/>]</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy into. Used for provider configuration, regional service ARNs, and region-specific resources (for example, ELB log delivery account mapping). | `string` | `"us-east-1"` | no |
| <a name="input_base_domain"></a> [base\_domain](#input\_base\_domain) | Base DNS domain hosted in Route53. Used to generate per-app FQDNs (for example, app.base\_domain and base\_domain) and create ALB alias records. | `string` | `"example.com"` | no |
| <a name="input_cert_arn"></a> [cert\_arn](#input\_cert\_arn) | ACM certificate ARN used by the ALB HTTPS listener as the primary TLS certificate (passed as main\_cert\_arn). | `string` | `""` | no |
| <a name="input_env"></a> [env](#input\_env) | Deployment environment identifier (for example: dev, staging, prod). Used in name\_prefix, tags, log prefixes, and DNS/SSM path construction. | `string` | `"dev"` | no |
| <a name="input_natgw_count"></a> [natgw\_count](#input\_natgw\_count) | NAT Gateway strategy for the VPC. Supported values: "none" (0 NAT gateways), "one" (single NAT gateway), "all" (one NAT gateway per AZ). Affects NAT EIPs that are also allow-listed on the ALB security group. | `string` | `"one"` | no |
| <a name="input_network_config"></a> [network\_config](#input\_network\_config) | n/a | <pre>object({<br/>    base_domain         = string<br/>    account_id          = string<br/>    env                 = string<br/>    project             = string<br/>    aws_region          = string<br/>    az_num              = number<br/>    vpc_ip_block        = string<br/>    subnet_cidr_private = string<br/>    subnet_cidr_public  = string<br/>    new_bits_private    = number<br/>    new_bits_public     = number<br/>    natgw_count         = string<br/>    public_ips          = map(string)<br/>    public_ips_v6       = map(string)<br/>    app_ports           = list(number)<br/>    common_tags         = map(string)<br/>  })</pre> | <pre>{<br/>  "account_id": "",<br/>  "app_ports": [<br/>    80,<br/>    443<br/>  ],<br/>  "aws_region": "us-east-1",<br/>  "az_num": 3,<br/>  "base_domain": "example.com",<br/>  "common_tags": {<br/>    "Env": "dev",<br/>    "ManagedBy": "terraform",<br/>    "Project": "default"<br/>  },<br/>  "env": "dev",<br/>  "natgw_count": "none",<br/>  "new_bits_private": 2,<br/>  "new_bits_public": 2,<br/>  "project": "default",<br/>  "public_ips": {<br/>    "0.0.0.0/0": "Open"<br/>  },<br/>  "public_ips_v6": {<br/>    "::/0": "Open"<br/>  },<br/>  "subnet_cidr_private": "172.27.72.0/24",<br/>  "subnet_cidr_public": "172.27.73.0/24",<br/>  "vpc_ip_block": "172.27.72.0/22"<br/>}</pre> | no |
| <a name="input_org"></a> [org](#input\_org) | Organization or tenant identifier used to build name\_prefix and hierarchical paths (org/project/env) for SSM and routing. | `string` | `"example"` | no |
| <a name="input_project"></a> [project](#input\_project) | Project identifier used in name\_prefix, tags, logs bucket naming, and routing/SSM path construction. | `string` | `"demo"` | no |

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