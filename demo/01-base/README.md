![banner](../../docs/imgs/banner.png)

# 01-base

This layer defines shared stack identity, naming, and tagging primitives.
It exports a single `base` object for downstream layers to consume via remote state.

Apply this layer first.

## What this layer provides

The `base` output contains:

- `org`
- `project`
- `env`
- `aws_region`
- `name_prefix`
- `common_tags`

## Usage

### Backend configuration

Example `backend.hcl`:

```hcl
bucket         = "terraform-demo-state-xxxx"
key            = "terraform/state/01-base.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-locks"
````

### Apply 01-base

Example `terraform.tfvars`:

```hcl
org        = "spr"
project    = "demo"
env        = "dev"
aws_region = "us-east-1"

extra_tags = {
  Owner = "platform"
}
```

## Consuming base outputs in downstream layers

In a downstream layer such as `03-vpc`, import the `base` object from remote state.

### Read remote state

```hcl
data "terraform_remote_state" "base" {
  backend = "s3"

  config = {
    bucket         = "terraform-demo-state-xxxx"
    key            = "terraform/state/01-base.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
  }
}
```

### Map into locals

```hcl
locals {
  base = data.terraform_remote_state.base.outputs.base
}
```

Optionally flatten:

```hcl
locals {
  name_prefix = local.base.name_prefix
  common_tags = local.base.common_tags
}
```

### Use in modules

```hcl
module "network" {
  source = "../../modules/network"

  name_prefix = local.base.name_prefix
  common_tags = local.base.common_tags

  # network-specific inputs
}
```

## Design notes

* Identity and naming live only in 01-base
* Downstream layers consume identity but never derive it
* Infrastructure outputs flow upward, identity flows downward
* The `base` object can be extended over time without breaking consumers

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region used by the root provider configuration. | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name, for example: dev, staging, prod. | `string` | n/a | yes |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Optional extra tags merged into common\_tags. | `map(string)` | `{}` | no |
| <a name="input_org"></a> [org](#input\_org) | Organization or company identifier used for naming and tags. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project identifier used for naming and tags. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_base"></a> [base](#output\_base) | All base primitives as a single object for downstream stacks via remote state. |

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