![banner](../../../docs/imgs/banner.png)

# 03-Prometheus Module Group Demo

This stack deploys **Prometheus on ECS Fargate** with CI/CD, ALB routing, secrets injection (SSM by path), CloudWatch logging, and optional blue green deployments. It is designed to be consumed after the Base and ECS Cluster module demos.

Prometheus is packaged as a container image that includes:

* `prometheus.yml` scrape config
* optional `rules/` (alert rules)
* readiness endpoint `/-/ready` and UI on port `9090`

> [!IMPORTANT]
>
> ### App name must be registered in the base configuration
>
> This demo **assumes the application name is pre-declared** in the Base module configuration.
>
> The `app_name` used by this module **must exist in the `app_names` array** defined in:
>
> ```
> demo/01-base/terraform.tfvars
> ```
>
> For this stack, ensure `prom` is present (example from your base tfvars):
>
> ```
> app_names = ["", "prom", "graf", "cwe", "app1", "hello"]
> ```
>
> If the application name is missing, derived locals such as the SSM path prefix will resolve to `null`, which causes Terraform to fail during plan or apply with errors like:
>
> * Missing required argument for `aws_ssm_parameters_by_path`
> * Invalid template interpolation due to a `null` path prefix

## What This Demo Provisions

* ECS service running Prometheus (rolling by default, optional blue green)
* Target group and ALB listener rule for `prom.<base_domain>`
* KMS encrypted CloudWatch log group (via `modules/ecs-service`)
* CI/CD pipeline (CodePipeline + CodeBuild) to build and deploy the container image
* Encrypted SNS topic for pipeline notifications (KMS CMK + topic policy)

## Prometheus Configuration Notes

The container image includes `app/prom/prometheus.yml`. In your current config, Prometheus scrapes:

* itself (`127.0.0.1:9090` and `localhost:9090`)
* CloudWatch Exporter at `cwe.demo.spacerocket.dev` (HTTPS with `insecure_skip_verify: true`)
* App1 at `app1.demo.spacerocket.dev` (HTTPS with `insecure_skip_verify: true`) and a local target `localhost:9091`

> [!CAUTION]
> `VOLUME ["/prometheus"]` is declared in the Dockerfile. On ECS Fargate, this is **ephemeral unless you add EFS**. For a long lived Prometheus, plan for EFS or a managed metrics backend. This demo focuses on the ECS, routing, and CI/CD patterns.

## Prerequisites

* Base Module Group applied and available via Terraform remote state (`demo/01-base`)
* ECS Cluster Module Group applied and available via Terraform remote state (`demo/02-ecs-cluster`)
* Valid ACM cert ARN for `demo.spacerocket.dev` (or your `base_domain`) and listener 443 in the base stack
* `prom` included in Base `app_names` (see IMPORTANT above)

## Tooling

This demo pins Terraform via `.tool-versions`:

* terraform `1.13.3`

## Inputs

This demo is driven by `terraform.tfvars` in this directory. Typical values:

* `app_name = "prom"`
* `port = 9090`
* `healthcheck_endpoint = "/-/ready"`
* `git_repo = "space-rocket/prometheus"`
* `git_branch = "main"`
* `image_repo = "space-rocket/prod/prometheus"`
* `image_tag = "latest"`
* `priority = 200`
* `deployment_strategy = "rolling"` (default) or `blue_green`

## How To Deploy

From `demo/03-apps/03-prometheus`:

1. Initialize and configure the remote backend:

   * Ensure `backend.hcl` exists locally (it is ignored by git in other app demos)
   * Run:

     * `terraform init -backend-config=backend.hcl`

2. Plan:

   * `terraform plan`

3. Apply:

   * `terraform apply`

## Accessing Prometheus

Once applied, Prometheus should be reachable at:

* `https://prom.<base_domain>`
* Example (from your base tfvars): `https://prom.demo.spacerocket.dev`

Common endpoints:

* `/-/ready` (readiness)
* `/metrics` (Prometheus metrics about Prometheus)
* `/graph` (classic UI)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.30.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_codepipeline"></a> [codepipeline](#module\_codepipeline) | ../../../modules/codepipeline | n/a |
| <a name="module_ecs_service"></a> [ecs\_service](#module\_ecs\_service) | ../../../modules/ecs-service | n/a |
| <a name="module_target_group"></a> [target\_group](#module\_target\_group) | ../../../modules/tg-fargate | n/a |
| <a name="module_target_group_green"></a> [target\_group\_green](#module\_target\_group\_green) | ../../../modules/tg-fargate | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lb_listener.test_8080](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_sns_topic.codepipeline_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.sns_topic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameters_by_path.all_app_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameters_by_path) | data source |
| [terraform_remote_state.alb](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.ecs_cluster](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.network](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.sns](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_state_key"></a> [alb\_state\_key](#input\_alb\_state\_key) | State key for the alb stack | `string` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Application name | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | n/a | yes |
| <a name="input_base_state_key"></a> [base\_state\_key](#input\_base\_state\_key) | State key for the base stack | `string` | n/a | yes |
| <a name="input_codebuild_compute_type"></a> [codebuild\_compute\_type](#input\_codebuild\_compute\_type) | Compute type for CodeBuild (e.g. BUILD\_GENERAL1\_MEDIUM) | `string` | n/a | yes |
| <a name="input_codebuild_image"></a> [codebuild\_image](#input\_codebuild\_image) | CodeBuild image to use (e.g. aws/codebuild/amazonlinux-aarch64-standard:3.0) | `string` | n/a | yes |
| <a name="input_deployment_strategy"></a> [deployment\_strategy](#input\_deployment\_strategy) | rolling or blue\_green | `string` | `"rolling"` | no |
| <a name="input_ecs_cluster_state_key"></a> [ecs\_cluster\_state\_key](#input\_ecs\_cluster\_state\_key) | State key for the ecs\_cluster stack | `string` | n/a | yes |
| <a name="input_fargate_cpu"></a> [fargate\_cpu](#input\_fargate\_cpu) | The amount of CPU (in CPU units) to allocate for the Fargate task. Valid values are 256, 512, 1024, 2048, or 4096. | `number` | n/a | yes |
| <a name="input_fargate_memory"></a> [fargate\_memory](#input\_fargate\_memory) | The amount of memory (in MiB) to allocate for the Fargate task. Must be compatible with the selected CPU value. | `number` | n/a | yes |
| <a name="input_git_branch"></a> [git\_branch](#input\_git\_branch) | Branch name to trigger the pipeline | `string` | `"main"` | no |
| <a name="input_git_repo"></a> [git\_repo](#input\_git\_repo) | GitHub repo full path, e.g., org/repo | `string` | n/a | yes |
| <a name="input_healthcheck_endpoint"></a> [healthcheck\_endpoint](#input\_healthcheck\_endpoint) | n/a | `string` | `"/health"` | no |
| <a name="input_healthcheck_interval"></a> [healthcheck\_interval](#input\_healthcheck\_interval) | n/a | `number` | `10` | no |
| <a name="input_healthcheck_retries"></a> [healthcheck\_retries](#input\_healthcheck\_retries) | n/a | `number` | `5` | no |
| <a name="input_healthcheck_start_period"></a> [healthcheck\_start\_period](#input\_healthcheck\_start\_period) | n/a | `number` | `30` | no |
| <a name="input_healthcheck_timeout"></a> [healthcheck\_timeout](#input\_healthcheck\_timeout) | n/a | `number` | `5` | no |
| <a name="input_image_repo"></a> [image\_repo](#input\_image\_repo) | Name of the ECR image repository | `string` | n/a | yes |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Tag of the ECR image to deploy | `string` | n/a | yes |
| <a name="input_lock_table_name"></a> [lock\_table\_name](#input\_lock\_table\_name) | DynamoDB table used for Terraform state locking | `string` | n/a | yes |
| <a name="input_network_state_key"></a> [network\_state\_key](#input\_network\_state\_key) | State key for the network stack | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | n/a | `number` | n/a | yes |
| <a name="input_priority"></a> [priority](#input\_priority) | Should be 100 higher then the previous app deployed | `number` | n/a | yes |
| <a name="input_sns_state_key"></a> [sns\_state\_key](#input\_sns\_state\_key) | State key for the sns stack | `string` | n/a | yes |
| <a name="input_state_bucket"></a> [state\_bucket](#input\_state\_bucket) | S3 bucket storing the base stack Terraform state | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb"></a> [alb](#output\_alb) | ALB listeners and target groups. |
| <a name="output_app"></a> [app](#output\_app) | Application-level configuration and routing details. |
| <a name="output_app_host_header"></a> [app\_host\_header](#output\_app\_host\_header) | Host header used by the ALB listener rule for routing. |
| <a name="output_app_image"></a> [app\_image](#output\_app\_image) | Full ECR image reference used by the ECS task definition. |
| <a name="output_app_name"></a> [app\_name](#output\_app\_name) | Logical application name used for naming and resource scoping. |
| <a name="output_app_port"></a> [app\_port](#output\_app\_port) | Container port exposed by the application. |
| <a name="output_app_url"></a> [app\_url](#output\_app\_url) | Primary HTTPS URL for the app when root domain is configured in base remote state. |
| <a name="output_codedeploy_app_name"></a> [codedeploy\_app\_name](#output\_codedeploy\_app\_name) | CodeDeploy application name when using blue\_green. |
| <a name="output_codedeploy_deployment_group_name"></a> [codedeploy\_deployment\_group\_name](#output\_codedeploy\_deployment\_group\_name) | CodeDeploy deployment group name when using blue\_green. |
| <a name="output_deployment_strategy"></a> [deployment\_strategy](#output\_deployment\_strategy) | Deployment strategy for the ECS service (rolling or blue\_green). |
| <a name="output_ecs"></a> [ecs](#output\_ecs) | ECS cluster, service, and task definition outputs. |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | ECS cluster id from remote state. |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | ECS cluster name from remote state. |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | ECS service name created for this app. |
| <a name="output_ecs_task_definition_arn"></a> [ecs\_task\_definition\_arn](#output\_ecs\_task\_definition\_arn) | ECS task definition ARN for the app. |
| <a name="output_ecs_task_definition_family"></a> [ecs\_task\_definition\_family](#output\_ecs\_task\_definition\_family) | ECS task definition family for the app. |
| <a name="output_ecs_task_definition_revision"></a> [ecs\_task\_definition\_revision](#output\_ecs\_task\_definition\_revision) | ECS task definition revision number for the app. |
| <a name="output_ecs_task_role_name"></a> [ecs\_task\_role\_name](#output\_ecs\_task\_role\_name) | IAM role name assumed by the ECS task. |
| <a name="output_git_branch"></a> [git\_branch](#output\_git\_branch) | Git branch used by the pipeline source action. |
| <a name="output_git_repo"></a> [git\_repo](#output\_git\_repo) | GitHub repository used by the pipeline source action. |
| <a name="output_healthcheck_endpoint"></a> [healthcheck\_endpoint](#output\_healthcheck\_endpoint) | HTTP healthcheck endpoint used by ALB and ECS health checks. |
| <a name="output_image_repo"></a> [image\_repo](#output\_image\_repo) | ECR repository name used by the build. |
| <a name="output_image_tag"></a> [image\_tag](#output\_image\_tag) | Image tag input used by the service config. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | CloudWatch Logs group name used for ECS task and pipeline logs. |
| <a name="output_path_prefix"></a> [path\_prefix](#output\_path\_prefix) | Base path prefix resolved from base\_outputs.path\_prefix\_map for this app. |
| <a name="output_pipeline"></a> [pipeline](#output\_pipeline) | CI/CD, CodeDeploy, and notification resources. |
| <a name="output_prod_listener_arn"></a> [prod\_listener\_arn](#output\_prod\_listener\_arn) | ALB HTTPS listener ARN used for production traffic routing. |
| <a name="output_runtime"></a> [runtime](#output\_runtime) | Runtime logging and secret resolution paths. |
| <a name="output_sns_kms_alias"></a> [sns\_kms\_alias](#output\_sns\_kms\_alias) | KMS alias name used for the SNS topic key. |
| <a name="output_sns_kms_key_arn"></a> [sns\_kms\_key\_arn](#output\_sns\_kms\_key\_arn) | KMS key ARN used to encrypt the SNS topic. |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | SNS topic ARN for CodePipeline and deployment notifications. |
| <a name="output_ssm_secret_path_prefix"></a> [ssm\_secret\_path\_prefix](#output\_ssm\_secret\_path\_prefix) | SSM Parameter Store secret path prefix resolved from base outputs. |
| <a name="output_target_group_blue_arn"></a> [target\_group\_blue\_arn](#output\_target\_group\_blue\_arn) | Target group ARN used for production traffic. |
| <a name="output_target_group_blue_name"></a> [target\_group\_blue\_name](#output\_target\_group\_blue\_name) | Target group name used for production traffic. |
| <a name="output_target_group_green_arn"></a> [target\_group\_green\_arn](#output\_target\_group\_green\_arn) | Target group ARN used for green traffic when using blue\_green. |
| <a name="output_target_group_green_name"></a> [target\_group\_green\_name](#output\_target\_group\_green\_name) | Target group name used for green traffic when using blue\_green. |
| <a name="output_task_name"></a> [task\_name](#output\_task\_name) | Task or service name prefix used across resources. |
| <a name="output_test_listener_arn"></a> [test\_listener\_arn](#output\_test\_listener\_arn) | ALB test listener ARN used by CodeDeploy for blue\_green. |

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