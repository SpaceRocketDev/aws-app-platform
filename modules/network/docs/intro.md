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