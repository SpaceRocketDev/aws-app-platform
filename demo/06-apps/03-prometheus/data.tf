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

data "terraform_remote_state" "sns" {
  backend = "s3"

  config = {
    bucket       = var.state_bucket
    key          = var.sns_state_key
    region       = var.aws_region
    use_lockfile = true
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"

  config = {
    bucket       = var.state_bucket
    key          = var.alb_state_key
    region       = var.aws_region
    use_lockfile = true
  }
}

data "terraform_remote_state" "ecs_cluster" {
  backend = "s3"

  config = {
    bucket       = var.state_bucket
    key          = var.ecs_cluster_state_key
    region       = var.aws_region
    use_lockfile = true
  }
}
