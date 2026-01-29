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