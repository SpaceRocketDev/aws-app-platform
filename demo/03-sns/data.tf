data "terraform_remote_state" "base" {
  backend = "s3"

  config = {
    bucket       = var.base_state_bucket
    key          = var.base_state_key
    region       = var.aws_region
    use_lockfile = true
  }
}
