data "terraform_remote_state" "base" {
  backend = "s3"

  config = {
    bucket       = var.state_bucket
    key          = var.base_state_key
    region       = var.aws_region
    use_lockfile = true
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket       = var.state_bucket
    key          = var.network_state_key
    region       = var.aws_region
    use_lockfile = true
  }
}
