# data "aws_acm_certificate" "main" {
#   domain      = var.alb_config.main_domain
#   statuses    = ["ISSUED"]
#   most_recent = true
# }

# data "aws_acm_certificate" "additional" {
#   for_each    = toset(var.alb_config.additional_domains)
#   domain      = each.key
#   statuses    = ["ISSUED"]
#   most_recent = true
# }
