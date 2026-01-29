module "sns_dev_alerts" {
  source = "../../modules/sns"
  sns_config = {
    account_id  = local.account_id
    env         = local.env
    project     = local.project
    region      = local.aws_region
    name_prefix = local.name_prefix
    common_tags = local.common_tags

    topic_name = local.topic_name

    subscriptions = {
      admin = {
        protocol = "email"
        endpoint = var.admin_email
      }
    }
  }
}
