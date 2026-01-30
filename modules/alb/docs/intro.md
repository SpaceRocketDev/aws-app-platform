# ALB Module

This module provisions a production ready **public Application Load Balancer (ALB)** for ECS/Fargate style workloads.

It creates a dualstack, internet-facing ALB with an HTTP listener that redirects to HTTPS, an HTTPS listener with a configurable TLS policy and ACM certificate, an opinionated security group allowlist, and operational guardrails like access logging and 5xx alarms wired to SNS.

This module intentionally does **not** create target groups or listener rules for your applications. Downstream stacks (for example an `ecs-service` or `tg-fargate` module) should attach target groups and add listener rules using the exported listener and ALB outputs.

## What this module provisions

- Public ALB (`aws_lb`) with HTTP/2 enabled and dualstack addressing
- Listener `:80` redirecting to `:443`
- Listener `:443` using `lb_ssl_policy` and `main_cert_arn`
  - Default response is a fixed **403 Access denied** until downstream listener rules are added
- ALB security group:
  - Ingress `80`, `443`, and `8080` from `alb_config.public_ips` (IPv4) and `alb_config.public_ips_v6` (IPv6)
  - Optional ingress `80` and `443` from `alb_config.nat_gateway_eips` (useful when internal callers egress via NAT)
  - Egress allow all (IPv4 and IPv6)
- S3 bucket for ALB access logs (required encryption mode is **SSE-S3 / AES256**)
  - Lifecycle expiration for log objects
  - Bucket policy for ELB log delivery and regional ELB root account delivery
  - Public access block and ownership controls
  - Optional EventBridge notifications
- Optional separate S3 bucket for **server access logs** of the ALB logs bucket (auditing who accessed the ALB log bucket)
  - KMS encrypted, versioned, lifecycle managed
- CloudWatch alarms:
  - `HTTPCode_ELB_5XX_Count`
  - `HTTPCode_Target_5XX_Count`
  - Alarm actions published to `alb_config.alarm_sns_topic_arn`

## Inputs

This module uses a single composite input: `alb_config`.

At minimum you will provide:
- VPC and public subnets for the ALB attachment
- The ACM certificate ARN and TLS policy
- Access logs bucket name and prefix
- An SNS topic ARN for alarm actions
- A CIDR allowlist for inbound traffic

## Usage

### Example

```hcl
module "alb" {
  source = "./modules/alb"

  alb_config = {
    account_id  = local.base.account_id
    env         = local.base.env
    project     = local.base.project
    name_prefix = local.base.name_prefix
    aws_region  = local.base.aws_region

    vpc        = module.network.vpc
    lb_subnets = module.network.subnets_public

    lb_ssl_policy = "ELBSecurityPolicy-TLS13-1-3-FIPS-2023-04"
    main_cert_arn = var.cert_arn

    main_domain        = var.base_domain
    additional_domains = values(local.fqdn_map)

    # Optional Route53 aliases
    create_aliases = [
      for app, fqdn in local.fqdn_map : {
        name = fqdn
        zone = var.base_domain
      }
    ]

    # Ingress allowlists
    public_ips = {
      "203.0.113.10/32" = "Office"
      "198.51.100.0/24" = "VPN"
    }
    public_ips_v6 = {}

    # Optional: allow internal callers that egress via NAT
    natgw_count       = "one" # "none" | "one" | "all"
    nat_gateway_eips  = module.network.nat_gateway_eips

    # ALB access logs (ALB destination bucket must be SSE-S3 / AES256)
    logs_enabled             = true
    logs_prefix              = local.base.env
    logs_bucket              = local.logs_bucket
    logs_expiration          = 90
    logs_bucket_force_destroy = false

    # Optional: server access logging for the logs bucket (KMS encrypted)
    logs_access_enabled              = true
    logs_access_bucket               = null
    logs_access_prefix               = "s3-access-logs/"
    logs_access_expiration           = 365
    logs_access_bucket_force_destroy = false

    # Alarms
    alb_5xx_threshold    = 20
    target_5xx_threshold = 20
    alarm_sns_topic_arn  = module.sns_dev_alerts.topic_arn

    enable_deletion_protection = true
    common_tags                = local.base.common_tags
  }
}
````

### Notes

* The ALB access logs destination bucket **must** use **SSE-S3 (AES256)**. KMS is not supported for ALB delivery buckets.
* The HTTPS listener default action returns **403** until you add listener rules and target groups in a downstream module.
* If you set `nat_gateway_eips`, this module adds allow rules for those EIPs on ports `80` and `443`.
* `additional_domains` is informational. This module does not automatically request or attach additional ACM certificates.

## Related modules

* `modules/network` supplies the VPC, public subnets, and NAT gateway EIPs.
* `modules/tg-fargate` creates target groups and listener rules for services.
* `modules/ecs-service` typically consumes `listener_443_arn`, `alb_sg_id`, and ALB DNS outputs.
* `modules/sns` provides the SNS topic for ALB alarm notifications.
