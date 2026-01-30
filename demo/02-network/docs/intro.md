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

#### Import Network Remote State

**data.tf**
```hcl
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket       = var.state_bucket 
    key          = var.network_state_key
    region       = var.aws_region
    use_lockfile = true
  }
}
```