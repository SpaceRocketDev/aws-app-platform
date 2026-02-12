# data "aws_acm_certificate" "main" {
#   domain      = var.acm_config.base_domain
#   statuses    = ["ISSUED"]
#   most_recent = true
# }

