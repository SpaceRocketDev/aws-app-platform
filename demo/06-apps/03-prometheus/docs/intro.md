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
