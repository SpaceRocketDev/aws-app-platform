![banner](../../docs/imgs/banner.png)

## Network Module

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.19.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm_certs"></a> [acm\_certs](#module\_acm\_certs) | ../../modules/acm | n/a |
| <a name="module_alb"></a> [alb](#module\_alb) | ../../modules/alb | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../modules/network | n/a |
| <a name="module_sns_dev_alerts"></a> [sns\_dev\_alerts](#module\_sns\_dev\_alerts) | ../../modules/sns | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_cert_arn"></a> [additional\_cert\_arn](#input\_additional\_cert\_arn) | Additional ACM certificate ARN reserved for future use (not currently passed into the ALB module configuration). | `string` | `""` | no |
| <a name="input_admin_email"></a> [admin\_email](#input\_admin\_email) | Email address subscribed to the SNS alerts topic for CloudWatch alarms (ALB 5xx and target 5xx). | `string` | `"admin@example.com"` | no |
| <a name="input_alb_config"></a> [alb\_config](#input\_alb\_config) | n/a | <pre>object({<br/>    account_id                = string<br/>    env                       = string<br/>    project                   = string<br/>    name_prefix               = string<br/>    aws_region                = string<br/>    vpc                       = any<br/>    lb_subnets                = list(any)<br/>    lb_sg                     = any<br/>    lb_ssl_policy             = string<br/>    main_domain               = string<br/>    additional_domains        = list(string)<br/>    logs_enabled              = bool<br/>    logs_prefix               = string<br/>    logs_bucket               = string<br/>    logs_expiration           = number<br/>    logs_bucket_force_destroy = bool<br/>    main_cert_arn             = string<br/>    create_aliases = list(object({<br/>      name = string<br/>      zone = string<br/>    }))<br/>    alarm_sns_topic_name = string<br/>    common_tags          = map(string)<br/>    alb_5xx_threshold    = optional(number, 20)<br/>    target_5xx_threshold = optional(number, 20)<br/>  })</pre> | <pre>{<br/>  "account_id": "",<br/>  "additional_domains": [],<br/>  "alarm_sns_topic_name": "default-ecs-dev-alerts",<br/>  "alb_5xx_threshold": 20,<br/>  "aws_region": "us-east-1",<br/>  "common_tags": {<br/>    "Env": "dev",<br/>    "ManagedBy": "terraform",<br/>    "Project": "default"<br/>  },<br/>  "create_aliases": [],<br/>  "env": "dev",<br/>  "lb_sg": null,<br/>  "lb_ssl_policy": "ELBSecurityPolicy-TLS13-1-3-FIPS-2023-04",<br/>  "lb_subnets": [],<br/>  "logs_bucket": "default-dev-ecs-alb-logs",<br/>  "logs_bucket_force_destroy": false,<br/>  "logs_enabled": true,<br/>  "logs_expiration": 90,<br/>  "logs_prefix": "dev",<br/>  "main_cert_arn": "",<br/>  "main_domain": "example.com",<br/>  "name_prefix": "myapp-dev",<br/>  "project": "default",<br/>  "target_5xx_threshold": 20,<br/>  "vpc": null<br/>}</pre> | no |
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

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | AWS account ID for the deployment. In demos this is derived at runtime for portability; for production prefer an explicitly managed static mapping for any account-specific values. |
| <a name="output_additional_domains"></a> [additional\_domains](#output\_additional\_domains) | Additional domain names to include on the ALB certificate and/or DNS aliases. |
| <a name="output_admin_email"></a> [admin\_email](#output\_admin\_email) | Administrative email address used for alerting and notifications. |
| <a name="output_alarm_sns_topic_arn"></a> [alarm\_sns\_topic\_arn](#output\_alarm\_sns\_topic\_arn) | SNS topic ARN used for base alarms and notifications. |
| <a name="output_alb_5xx_threshold"></a> [alb\_5xx\_threshold](#output\_alb\_5xx\_threshold) | Threshold for ALB HTTP 5xx alarms. |
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ALB ARN used by downstream resources (for example, test listeners). |
| <a name="output_alb_arn_suffix"></a> [alb\_arn\_suffix](#output\_alb\_arn\_suffix) | ALB ARN suffix used for CloudWatch metrics and alarms. |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | ALB DNS name used for DNS aliasing and validation. |
| <a name="output_alb_listener_443_arn"></a> [alb\_listener\_443\_arn](#output\_alb\_listener\_443\_arn) | ARN of the ALB HTTPS (443) listener used by downstream ECS services. |
| <a name="output_alb_sg_id"></a> [alb\_sg\_id](#output\_alb\_sg\_id) | Security group ID attached to the ALB (referenced by downstream stacks). |
| <a name="output_allowed_ips"></a> [allowed\_ips](#output\_allowed\_ips) | Allowlist of public IPs or CIDRs used to restrict access where applicable. |
| <a name="output_app_names"></a> [app\_names](#output\_app\_names) | List of application identifiers used to build routing and secret path maps. |
| <a name="output_aws_region"></a> [aws\_region](#output\_aws\_region) | AWS region used by base and downstream stacks. |
| <a name="output_base_config"></a> [base\_config](#output\_base\_config) | Base configuration map exported for downstream stacks (apps, cluster, etc.) via remote state. |
| <a name="output_base_domain"></a> [base\_domain](#output\_base\_domain) | Base DNS domain for the environment (used to derive main\_domain and fqdn\_map). |
| <a name="output_base_outputs"></a> [base\_outputs](#output\_base\_outputs) | All base primitives as a single object for downstream stacks via remote state. |
| <a name="output_cert_arn"></a> [cert\_arn](#output\_cert\_arn) | ACM certificate ARN used by the ALB listener(s) and downstream test listeners. |
| <a name="output_common_tags"></a> [common\_tags](#output\_common\_tags) | Standard tags applied across resources (merged into downstream stacks). |
| <a name="output_env"></a> [env](#output\_env) | Environment name (for example: dev, stage, prod). Used for naming, logs prefixing, and tags. |
| <a name="output_fqdn_map"></a> [fqdn\_map](#output\_fqdn\_map) | Map of logical names to fully qualified domain names used by downstream stacks (for example, 'root' lookup). |
| <a name="output_lb_ssl_policy"></a> [lb\_ssl\_policy](#output\_lb\_ssl\_policy) | ALB TLS policy name used by listeners (also referenced by downstream test listeners). |
| <a name="output_logs_bucket"></a> [logs\_bucket](#output\_logs\_bucket) | S3 bucket name used for ALB access logs. |
| <a name="output_logs_bucket_force_destroy"></a> [logs\_bucket\_force\_destroy](#output\_logs\_bucket\_force\_destroy) | Whether the logs bucket may be force-destroyed (generally false for safety). |
| <a name="output_logs_enabled"></a> [logs\_enabled](#output\_logs\_enabled) | Whether ALB access logging is enabled for the environment. |
| <a name="output_logs_expiration"></a> [logs\_expiration](#output\_logs\_expiration) | S3 lifecycle expiration in days for access log objects. |
| <a name="output_logs_prefix"></a> [logs\_prefix](#output\_logs\_prefix) | S3 log prefix for ALB access logs (commonly set to env). |
| <a name="output_main_domain"></a> [main\_domain](#output\_main\_domain) | Primary domain name used by the ALB and DNS records (typically equals base\_domain). |
| <a name="output_name_prefix"></a> [name\_prefix](#output\_name\_prefix) | Shared name prefix used for naming resources and app task names in downstream modules. |
| <a name="output_natgw_count"></a> [natgw\_count](#output\_natgw\_count) | NAT gateway sizing selector passed into the network module (controls number of NAT gateways). |
| <a name="output_path_prefix_map"></a> [path\_prefix\_map](#output\_path\_prefix\_map) | Map of app name to normalized ALB path prefix (trailing slash removed) used by downstream ECS services. |
| <a name="output_path_prefixes"></a> [path\_prefixes](#output\_path\_prefixes) | List of per-app ALB path prefixes (used by downstream stacks for routing and naming). |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Private subnet IDs created by the base network module (used for Fargate tasks in downstream stacks). |
| <a name="output_project"></a> [project](#output\_project) | Project identifier used for naming and tagging across the stack. |
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | Derived project name in the form '<project>-<env>' used for consistent naming. |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Public subnet IDs created by the base network module. |
| <a name="output_region"></a> [region](#output\_region) | Alias of aws\_region for downstream compatibility. |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | Alias of alarm\_sns\_topic\_arn for downstream compatibility. |
| <a name="output_sns_topic_name"></a> [sns\_topic\_name](#output\_sns\_topic\_name) | SNS topic name used for base alerts and downstream integrations. |
| <a name="output_ssm_secret_path_prefix_map"></a> [ssm\_secret\_path\_prefix\_map](#output\_ssm\_secret\_path\_prefix\_map) | Map of app name to SSM parameter path prefix used by downstream stacks to resolve per-app secret locations. |
| <a name="output_ssm_secret_path_prefixes"></a> [ssm\_secret\_path\_prefixes](#output\_ssm\_secret\_path\_prefixes) | List of per-app SSM parameter path prefixes used by downstream stacks to locate secrets. |
| <a name="output_target_5xx_threshold"></a> [target\_5xx\_threshold](#output\_target\_5xx\_threshold) | Threshold for target HTTP 5xx alarms. |
| <a name="output_topic_name"></a> [topic\_name](#output\_topic\_name) | SNS topic name used by the base alerts topic. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID for the environment (consumed by downstream stacks). |

---

> [!TIP]
> #### Use SpaceRocket.Dev Terraform Reference Architectures for AWS
>
> Use SpaceRocket.Dev’s ready to use Terraform reference architectures for AWS to get up and running fast, without sacrificing security, ownership, or clarity.
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
> SpaceRocket.Dev is a solo DevSecOps consultancy based in San Francisco, focused on helping teams build secure, compliant, production ready AWS platforms using Terraform as the source of truth.
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