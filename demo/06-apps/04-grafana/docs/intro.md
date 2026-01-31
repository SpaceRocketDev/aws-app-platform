# 04-Grafana Module Group Demo

This stack deploys **Grafana on ECS Fargate** with CI/CD, ALB routing, secrets injection (SSM by path), CloudWatch logging, and optional blue green deployments.

Grafana is packaged as a container image that includes:

- `grafana.ini` base configuration
- Provisioned data sources (Prometheus and optional Postgres)
- Provisioned dashboards (JSON files under provisioning)
- Health endpoint `/api/health` on port `3000`

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
> For this stack, ensure `graf` is present (example from your base tfvars):
>
> ```
> app_names = ["", "prom", "graf", "cwe", "app1", "hello"]
> ```
>
> If the application name is missing, derived locals such as the SSM path prefix will resolve to `null`, which causes Terraform to fail during plan or apply with errors like:
>
> - Missing required argument for `aws_ssm_parameters_by_path`
> - Invalid template interpolation due to a `null` path prefix

## What This Demo Provisions

- ECS service running Grafana (rolling by default, optional blue green)
- Target group and ALB listener rule for `graf.<base_domain>`
- KMS encrypted CloudWatch log group (via `modules/ecs-service`)
- CI/CD pipeline (CodePipeline + CodeBuild) to build and deploy the container image
- Encrypted SNS topic for pipeline notifications (KMS CMK + topic policy)

## Grafana Configuration Notes

The container image includes:

- `app/grafana.ini`
- Data sources under `app/provisioning/datasources/`
  - `prometheus.yml` (Prometheus data source)
  - `postgres.yml` (Aurora Postgres data source template)
- Dashboards under `app/provisioning/dashboards/` and JSON dashboards under `app/provisioning/dashboards/json/`

If you want fully automated setup, move any sensitive values (admin password, datasource secrets) into SSM and inject them as runtime secrets/env vars rather than baking them into files.

> [!CAUTION]
> `VOLUME ["/var/lib/grafana"]` is declared in the Dockerfile. On ECS Fargate, this is **ephemeral unless you add EFS**.
>
> For long lived dashboards, users, and plugins, plan for EFS or an external persistence strategy. This demo focuses on ECS, routing, and CI/CD patterns.

## Prerequisites

- Base Module Group applied and available via Terraform remote state (`demo/01-base`)
- Network Module Group applied and available via Terraform remote state (`demo/02-network`)
- SNS Module Group applied and available via Terraform remote state (`demo/03-sns`)
- ALB Module Group applied and available via Terraform remote state (`demo/04-alb`)
- ECS Cluster Module Group applied and available via Terraform remote state (`demo/05-ecs-cluster`)
- Valid ACM cert ARN for your `base_domain` and listener 443 in the ALB stack
- `graf` included in Base `app_names` (see IMPORTANT above)
- If you are using the Prometheus data source, ensure your Prometheus endpoint is reachable from Grafana

## Tooling

This demo pins Terraform via `.tool-versions`:

- terraform `1.13.3`

## Inputs

This demo is driven by `terraform.tfvars` in this directory. Typical values:

- `app_name = "graf"`
- `port = 3000`
- `healthcheck_endpoint = "/api/health"`
- `git_repo = "space-rocket/grafana"`
- `git_branch = "main"`
- `image_repo = "space-rocket/prod/grafana"`
- `image_tag = "latest"`
- `priority = 500`
- `deployment_strategy = "rolling"` (default) or `blue_green`

## How To Deploy

From `demo/03-apps/04-grafana`:

1. Initialize and configure the remote backend:
   - Ensure `backend.hcl` exists locally (it is ignored by git in other app demos)
   - Run:
   - `terraform init -backend-config=backend.hcl`

2. Plan:
   - `terraform plan`

3. Apply:
   - `terraform apply`

## Accessing Grafana

Once applied, Grafana should be reachable at:

- `https://graf.<base_domain>`
- Example (from your base tfvars): `https://graf.demo.spacerocket.dev`

Common endpoints:

- `/api/health` (health)
- `/login` (UI login)
- `/` (Grafana UI)

If you provision dashboards, they should appear automatically after the service starts (Grafana provisioning scans at startup and then periodically based on your provider configuration).
