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
```

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

```bash
terraform init -backend-config=backend.hcl
terraform apply -var-file="terraform.tfvars"
```

## Consuming base outputs in downstream layers

In a downstream layer such as `03-vpc`, import the `base` object from remote state.

### Read remote state

```hcl
data "terraform_remote_state" "base" {
  backend = "s3"

  config = {
    bucket       = var.state_bucket 
    key          = var.base_state_key
    region       = var.aws_region
    use_lockfile = true
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