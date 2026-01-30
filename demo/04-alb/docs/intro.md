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
