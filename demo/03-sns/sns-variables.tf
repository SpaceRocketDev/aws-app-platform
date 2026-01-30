variable "sns_config" {
  type = object({
    account_id = string
    env        = string
    project    = string
    region     = string
    topic_name = string
    subscriptions = map(object({
      protocol = string
      endpoint = string
    }))
  })

  default = {
    account_id = ""
    env        = "dev"
    project    = "default"
    region     = "us-east-1"

    topic_name = "default-ecs-dev-alerts"

    subscriptions = {
      admin = {
        protocol = "email"
        endpoint = "admin@example.com"
      }
    }
  }
}
