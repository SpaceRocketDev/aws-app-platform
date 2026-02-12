# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AWS App Platform — a modular Terraform reference architecture for deploying containerized applications on AWS using ECS Fargate. Includes CI/CD (CodePipeline), observability (Prometheus/Grafana/CloudWatch), networking (VPC), and security defaults (KMS, least-privilege IAM, TLS 1.3).

## Common Commands

```bash
# Terraform workflow (run from any stack directory, e.g., demo/02-network/)
terraform init -backend-config=backend.hcl
terraform plan
terraform apply

# Generate module documentation (requires terraform-docs)
terraform-docs markdown table --config .terraform.docs.yml modules/<module-name>

# Build and push app container to ECR
./app1/ecr-build-push.sh

# Upload .env to SSM Parameter Store
./demo/06-apps/<app>/env/upload-env-to-ssm.sh
```

Tool versions are pinned via `.tool-versions` (asdf): **Terraform 1.13.3**.

## Architecture

### Module Layer (`modules/`)

Eight reusable Terraform modules, each accepting a **single composite input object** (e.g., `network_config`, `alb_config`, `ecs_service_config`) instead of many individual variables. All modules include HCL validation blocks on inputs.

| Module | Purpose |
|---|---|
| `network` | VPC, public/private subnets (1-6 AZs), NAT strategies (`none`/`one`/`all`), VPC Flow Logs, VPC Endpoints (SSM, Secrets Manager) |
| `alb` | Dualstack ALB, HTTP→HTTPS redirect, TLS 1.3, S3 access logs, 5xx alarms → SNS |
| `ecs-cluster` | ECS cluster, Fargate capacity providers, Container Insights, execution role |
| `ecs-service` | Task definition from template, rolling or blue/green deploys, KMS-encrypted CloudWatch logs, optional CodeDeploy |
| `codepipeline` | CodePipeline v2 (GitHub → CodeBuild → ECS deploy), KMS-encrypted S3 artifacts, cross-region support |
| `tg-fargate` | ALB target groups, health checks, listener rules, 5xx alarms |
| `sns` | KMS-encrypted SNS topics with flexible subscriptions |
| `aurora` | Placeholder/minimal |

### Demo Layer (`demo/`)

Layered reference stacks that chain via `terraform_remote_state`. Each stack has its own state file in S3 with DynamoDB locking.

```
01-base      → naming, tags, org/project/env identity
02-network   → VPC, subnets, NAT
03-sns       → alerting topics
04-alb       → load balancer + TLS
05-ecs-cluster → compute cluster
06-apps/     → application deployments (app1, cloudwatch-exporter, prometheus, grafana)
07-metrics   → observability scaffolding
```

### Application Layer (`app1/`)

Python 3.12 FastAPI microservice with Prometheus instrumentation (`/metrics`). Runs on Uvicorn in an Alpine Docker container. Health check endpoint: `/-/ready`. Container port: 9091.

## Terraform Conventions

- **File organization**: `variables.tf`, `outputs.tf`, `locals.tf`, `data.tf`, `providers.tf`, `versions.tf`, plus domain-specific files (e.g., `iam.tf`, `alb.tf`)
- **Naming**: `${org}-${project}-${env}` prefix (e.g., `spr-demo-dev-ecs-cluster`)
- **State**: S3 backend + DynamoDB locking, configured via `backend.hcl` (gitignored)
- **Secrets**: SSM Parameter Store at path `/${org}/${project}/${env}/${app_name}/*`
- **Provider**: AWS provider ~6.19
- **Security defaults**: KMS encryption everywhere, private subnets for tasks, no public IPs on Fargate, least-privilege IAM scoped to specific ARNs

## Git Conventions

- Main branch: `main`
- Feature branches: `modules/<name>` or descriptive names
- Commit messages: conventional format (`chore:`, `feat:`, `fix:`, `docs:`)
