# CodePipeline Module

Terraform module that provisions an AWS CodePipeline v2 for containerized ECS/Fargate services using CodeStar Connections (GitHub) and two CodeBuild projects (build + deploy). Supports rolling deployments via `ecs update-service` and optional blue/green deployments via CodeDeploy.

## What This Module Provisions

- A CodePipeline v2 with Source, Build, and Deploy stages
- A CodeStar Connections GitHub connection used by the Source stage
- Two CodeBuild projects:
  - **Build**: builds and pushes an image to ECR, emits `image_tag.txt`
  - **Deploy**: registers a new ECS task definition and deploys via ECS rolling or CodeDeploy blue/green
- KMS encrypted S3 buckets for pipeline artifacts and server access logs
- Optional cross region S3 replication (artifact + logs) via a dedicated replication role and replica KMS key
- IAM roles and least privilege policies for CodePipeline, CodeBuild, and S3 replication

## Inputs

This module is configured via a single object input: `codepipeline_config`.

> [!IMPORTANT]
> This module expects an existing ECR repository and an existing ECS service and cluster. It only wires CI/CD and deployment actions around them.

### codepipeline_config schema

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| account_id | AWS account id | string | `""` | yes |
| project | Project name used in tags/naming | string | `"default"` | yes |
| env | Environment name (dev, prod, etc.) | string | `"dev"` | yes |
| region | AWS region for the pipeline and primary buckets | string | `"us-east-1"` | yes |
| app_name | Logical app name (used for log stream prefix, etc.) | string | `"app"` | yes |
| task_name | Name prefix used for pipeline/resources | string | `"app"` | yes |
| log_group_name | CloudWatch log group prefix used by CodeBuild logs | string | `"/ecs/app"` | yes |
| git_repo | GitHub repo in `owner/repo` format | string | `"owner/repo"` | yes |
| git_branch | Branch to trigger pipeline | string | `"main"` | yes |
| ecs_cluster_name | ECS cluster name containing the service | string | `"default"` | yes |
| ecs_service_name | ECS service name to deploy | string | `"app"` | yes |
| image_repo | ECR repository name (repo path only, no registry) | string | `"123456789012.dkr.ecr.us-east-1.amazonaws.com/app"` | yes |
| port | Container port used for task definition and CodeDeploy spec | number | `8080` | yes |
| healthcheck_endpoint | HTTP health endpoint used by the ECS container healthcheck | string | `"/"` | yes |
| ssm_secret_path_prefix | SSM Parameter Store base path for secrets (used by deploy buildspec) | string | `"/app/dev"` | yes |
| app_secrets | ECS secrets list in `{ name, valueFrom }` shape | list(object) | `[]` | yes |
| app_environments | ECS env var list in `{ name, value }` shape | list(object) | `[]` | yes |
| fargate_cpu | ECS task cpu units | number | `256` | yes |
| fargate_memory | ECS task memory MiB | number | `512` | yes |
| fargate_ecs_task_role | Task role name used when registering task definition | string | `""` | yes |
| fargate_ecs_execution_role | Execution role ARN used when registering task definition | string | `""` | yes |
| codebuild_compute_type | CodeBuild compute type | string | `"BUILD_GENERAL1_SMALL"` | yes |
| codebuild_image | CodeBuild image | string | `"aws/codebuild/standard:7.0"` | yes |
| deploy_provider | Deployment mode selector: `"ECS"` or `"CodeDeployToECS"` | string | `"ECS"` | yes |
| codedeploy_app | CodeDeploy app name (required when `deploy_provider = "CodeDeployToECS"`) | string | `null` | no |
| codedeploy_dg | CodeDeploy deployment group name (required when `deploy_provider = "CodeDeployToECS"`) | string | `null` | no |

## How It Works

### Pipeline stages

1. **Source**
   - Uses CodeStarSourceConnection with your GitHub repo/branch
   - Outputs `source_output` using `CODEBUILD_CLONE_REF`

2. **Build**
   - Builds and pushes a Docker image to ECR
   - Emits `image_tag.txt` for downstream stages

3. **Deploy**
   - Registers a new ECS task definition using the image tag
   - If `deploy_provider = "ECS"`: runs `aws ecs update-service --force-new-deployment`
   - If `deploy_provider = "CodeDeployToECS"`: creates a CodeDeploy deployment using generated AppSpec content

## Security Notes

- S3 artifact and access logs buckets are:
  - Blocked from public access
  - Enforced bucket owner ownership
  - KMS encrypted
  - Versioned
  - Lifecycle managed (artifacts expire, logs retained longer)
- IAM policies enforce:
  - TLS only (`aws:SecureTransport`)
  - KMS encryption requirements for S3 writes
  - Scoped ECR access to a single repository
  - Scoped ECS UpdateService access to a single service ARN
  - PassRole limited to ECS tasks service

## Outputs

Output values are resolved from the `outputs_map` object, where each entry provides a resolved value along with its description, schema version, and the module version it was introduced in via since. Ex: `outputs_map.value.port.value`

| Name | Description |
|------|-------------|
| port | Port the app container listens on. |

## Related Projects

- `modules/ecs-service`  
  Provisions the ECS service and task role used by the deploy stage.

- `modules/tg-fargate`  
  Provisions ALB target groups and routing that front the ECS service.

- `demo/03-apps/*`  
  Example stacks that wire `modules/codepipeline` into an application deployment.
