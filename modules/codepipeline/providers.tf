# providers.tf in this module
provider "aws" {
  region = local.region
}

provider "aws" {
  alias  = "replica"
  region = "us-west-2" # choose your replica region
}
