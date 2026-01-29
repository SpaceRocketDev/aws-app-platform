![banner](../../docs/imgs/banner.png)

# Network Module

Terraform module that provisions a production ready **AWS VPC networking foundation** intended to be reused across application, compute, and data stacks.

This module is responsible only for **network primitives and connectivity**, and deliberately avoids application specific concerns.

It provides a consistent, IPv6 enabled VPC layout with controlled egress, private service access, and opinionated defaults suitable for production environments.

## Features

* VPC with DNS support and generated IPv6 CIDR block
* Public and private subnets spread across a configurable number of AZs
* Internet Gateway and routing for public subnets
* Optional NAT Gateway strategies for private subnet egress (`none`, `one`, `all`)
* VPC Flow Logs delivered to CloudWatch Logs using a dedicated KMS key and least privilege IAM role
* Interface VPC Endpoints for AWS Systems Manager and Secrets Manager with Private DNS enabled
* Dedicated security group for VPC endpoints
* Exports core network objects for consumption by downstream modules

This module is designed to act as the **networking baseline** for ECS, EKS, ALB, RDS, and other infrastructure layers that attach to an existing VPC.

## What This Module Provisions

* `aws_vpc` with:

  * DNS hostnames and DNS support enabled
  * Generated IPv6 CIDR block assigned
* `aws_internet_gateway`
* Subnets:

  * `aws_subnet.public` across `network_config.az_num` AZs
  * `aws_subnet.private` across `network_config.az_num` AZs
  * Public subnets do **not** auto-assign public IPv4 on launch (`map_public_ip_on_launch = false`)
* Route tables and routes:

  * Public route table with `0.0.0.0/0` to the Internet Gateway
  * Private route tables with optional `0.0.0.0/0` routes to NAT Gateway(s)
* NAT Gateways (optional):

  * `aws_eip.ngw` Elastic IPs (customer-managed) for NAT egress
  * `aws_nat_gateway.ngw` in public subnets
* VPC Flow Logs:

  * `aws_cloudwatch_log_group.vpc_flow` (KMS-encrypted)
  * `aws_kms_key.cloudwatch_logs` + alias for CloudWatch Logs encryption
  * `aws_iam_role.vpc_flow` + inline policy to write to the flow log group
  * `aws_flow_log.this` with `traffic_type = "ALL"`
* VPC Endpoints:

  * Interface endpoint for SSM (`com.amazonaws.<region>.ssm`) associated to **public** subnets
  * Interface endpoint for Secrets Manager (`com.amazonaws.<region>.secretsmanager`) associated to **private** subnets
  * Endpoint security group `aws_security_group.ssm_vpc` (egress allow all)

## Usage

### Example

```hcl
module "network" {
  source = "./modules/network"

  network_config = {
    project_name       = "${var.project}-${var.env}"
    name_prefix        = "${var.org}-${var.project}-${var.env}"
    base_domain        = var.base_domain

    account_id         = local.account_id
    env                = var.env
    project            = var.project
    aws_region         = var.aws_region

    # Topology
    az_num             = 3
    vpc_ip_block       = "172.27.72.0/22"
    subnet_cidr_private = "172.27.72.0/24"
    subnet_cidr_public  = "172.27.73.0/24"
    new_bits_private   = 2
    new_bits_public    = 2

    # NAT strategy: "none" | "one" | "all"
    natgw_count        = var.natgw_count

    # Informational allowlists/ports (primarily consumed by other modules)
    public_ips         = { "104.193.171.254/32" = "Allowed IP" }
    public_ips_v6      = {}
    app_ports          = [80, 443]

    common_tags = {
      Env       = var.env
      ManagedBy = "terraform"
      Project   = var.project
    }
  }
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.28.0 |

## Modules

No modules.



## Resources

| Name | Type | Description |
|------|------|-------------|
| [aws_cloudwatch_log_group.vpc_flow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource | VPC Flow Logs log group (KMS-encrypted) |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource | Default Security Group for the VPC (kept empty to avoid accidental open rules) |
| [aws_eip.ngw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource | Customer-managed Elastic IPs for NAT Gateway egress (stable allowlist targets) |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource | VPC Flow Logs (ALL traffic) delivered to CloudWatch Logs using the dedicated IAM role |
| [aws_iam_role.vpc_flow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource | IAM role assumed by VPC Flow Logs service to publish flow logs to CloudWatch Logs |
| [aws_iam_role_policy.vpc_flow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource | Inline policy allowing the VPC Flow Logs IAM role to write to the VPC flow log group |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource | Internet Gateway for public subnet egress/ingress |
| [aws_kms_alias.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource | Friendly alias for the CloudWatch Logs KMS key |
| [aws_kms_key.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource | KMS CMK for encrypting CloudWatch Logs (used by VPC Flow Logs log group) |
| [aws_nat_gateway.ngw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource | NAT Gateways providing private subnet egress via the public subnets |
| [aws_route.private_natgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource | Default route from private route tables to NAT Gateway(s) when enabled |
| [aws_route.route_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource | Default route from the public route table to the Internet Gateway |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource | Private route tables (one per private subnet/AZ) |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource | Public route table shared by all public subnets |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource | Associate each private subnet with its corresponding private route table |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource | Associate each public subnet with the public route table |
| [aws_security_group.ssm_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource | Security group attached to VPC Interface Endpoints (SSM, Secrets Manager) |
| [aws_security_group_rule.ssm_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource | Egress rule: allow all outbound traffic from the endpoint ENIs |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource | Private subnets across AZs (used for workloads like ECS/Fargate tasks) |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource | Public subnets across AZs (do not auto-assign public IPv4 on launch) |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource | Primary VPC for the stack (DNS enabled, IPv6 assigned) |
| [aws_vpc_endpoint.secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource | Interface VPC Endpoint for AWS Secrets Manager with Private DNS enabled |
| [aws_vpc_endpoint.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource | Interface VPC Endpoint for AWS Systems Manager (SSM) with Private DNS enabled |
| [aws_vpc_endpoint_subnet_association.secretsmanager_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_subnet_association) | resource | Associate the Secrets Manager VPC Endpoint with all private subnets |
| [aws_vpc_endpoint_subnet_association.ssm_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_subnet_association) | resource | Associate the SSM VPC Endpoint with all public subnets |
| [aws_availability_zones.az](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source | Availability zones used to spread subnets across the configured AZ count |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source | Retrieves the AWS account ID at runtime |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network_config"></a> [network\_config](#input\_network\_config) | Composite config for VPC, subnets, NAT strategy, endpoints, and tags. | <pre>object({<br/>    project_name        = string<br/>    name_prefix         = string<br/>    account_id          = string<br/>    aws_region          = string<br/>    az_num              = number<br/>    vpc_ip_block        = string<br/>    subnet_cidr_private = string<br/>    subnet_cidr_public  = string<br/>    new_bits_private    = number<br/>    new_bits_public     = number<br/>    natgw_count         = string # "none" | "one" | "all"<br/>    common_tags         = map(string)<br/>  })</pre> | <pre>{<br/>  "account_id": "",<br/>  "aws_region": "us-east-1",<br/>  "az_num": 3,<br/>  "common_tags": {<br/>    "Env": "dev",<br/>    "ManagedBy": "terraform",<br/>    "Project": "default"<br/>  },<br/>  "name_prefix": "myapp-dev",<br/>  "natgw_count": "none",<br/>  "new_bits_private": 2,<br/>  "new_bits_public": 2,<br/>  "project_name": "myapp-dev",<br/>  "subnet_cidr_private": "172.27.72.0/24",<br/>  "subnet_cidr_public": "172.27.73.0/24",<br/>  "vpc_ip_block": "172.27.72.0/22"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name_prefix"></a> [name\_prefix](#output\_name\_prefix) | Name prefix used for resources created by this module. |
| <a name="output_nat_gateway_eips"></a> [nat\_gateway\_eips](#output\_nat\_gateway\_eips) | List of NAT Gateway Elastic IP addresses |
| <a name="output_network"></a> [network](#output\_network) | Network primitives for downstream stacks via remote state (stable contract). |
| <a name="output_subnets_private"></a> [subnets\_private](#output\_subnets\_private) | n/a |
| <a name="output_subnets_public"></a> [subnets\_public](#output\_subnets\_public) | n/a |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | n/a |

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