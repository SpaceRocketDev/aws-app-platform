terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.19"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }
  backend "s3" {}
}
