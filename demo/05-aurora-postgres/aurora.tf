module "aurora" {
  source = "../../modules/aurora"

  aurora_config = {
    account_id  = local.account_id
    env         = local.base.env
    project     = local.base.project
    name_prefix = local.name_prefix
    aws_region  = local.base.aws_region

    engine_version = var.engine_version
    database_name  = var.db_name

    min_acu        = var.min_acu
    max_acu        = var.max_acu
    instance_count = var.instance_count

    vpc_id             = local.network.vpc.id
    private_subnet_ids = [for s in local.network.private_subnet_ids : s.id]

    deletion_protection = var.deletion_protection
    skip_final_snapshot = var.skip_final_snapshot

    common_tags = local.common_tags
  }
}
