# 01-App1 Module Group

This stack deploys a production ready ECS Fargate application with CI/CD, ALB routing, secrets injection, logging, and optional blue green deployments.

It is designed to be consumed after the Base, Network, SNS, ALB, and ECS Cluster module demos.

> [!IMPORTANT]
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
> If the application name is missing, derived locals such as `path_prefix` and `ssm_secret_path_prefix` will resolve to `null`, which causes Terraform to fail during plan or apply with errors like:
>
> - Missing required argument for `aws_ssm_parameters_by_path`
> - Invalid template interpolation due to a `null` path prefix
>
> Before running this demo, ensure the application name is explicitly listed in the base configuration so all downstream paths, log groups, and secrets can be resolved correctly.

## Usage

### Backend configuration

This stack uses an `s3` backend. Example `backend.hcl`:

```hcl
bucket         = "terraform-demo-state-dce2cf761e97"
key            = "terraform/state/hello-world.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-locks"
````

### Example `terraform.tfvars`

The values below reflect the current input variables for this stack and the remote state keys it consumes.

```hcl
# Remote state storage
state_bucket     = "terraform-demo-state-dce2cf761e97"
lock_table_name  = "terraform-state-locks"
aws_region       = "us-east-1"

# Upstream stack state keys
base_state_key        = "terraform/state/base.tfstate"
network_state_key     = "terraform/state/network.tfstate"
sns_state_key         = "terraform/state/sns.tfstate"
alb_state_key         = "terraform/state/alb.tfstate"
ecs_cluster_state_key = "terraform/state/ecs-cluster.tfstate"

# App identity (must exist in base.app_names)
app_name = "app1"

# CI/CD source
git_repo   = "space-rocket/hello-world"
git_branch = "main"

# Container runtime
port       = 9091
image_repo  = "space-rocket/prod/hello-world"
image_tag   = "latest"

# CodeBuild
codebuild_compute_type = "BUILD_GENERAL1_MEDIUM"
codebuild_image        = "aws/codebuild/amazonlinux-aarch64-standard:3.0"

# ECS task sizing
fargate_cpu    = 2048
fargate_memory = 4096

# Health checks (matches app/Dockerfile)
healthcheck_endpoint = "/-/ready"

# ALB listener rule priority
priority = 100

# Deployment strategy
# deployment_strategy = "rolling"
# deployment_strategy = "blue_green"
```

### Apply

```bash
terraform init -backend-config=backend.hcl
terraform apply -var-file="terraform.tfvars"
```

## Notes

* `priority` must be unique per application listener rule. A common convention is increments of 100 per app.
* If `deployment_strategy = "blue_green"`, this stack creates a test listener and a green target group for CodeDeploy traffic shifting.
* Secrets are loaded from SSM Parameter Store via `aws_ssm_parameters_by_path` using the per app prefix from base remote state.
