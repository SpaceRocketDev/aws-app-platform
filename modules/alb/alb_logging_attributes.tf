# locals {
#   logs_bucket_name = aws_s3_bucket.logs["this"].id
#   logs_prefix      = var.alb_config.logs_prefix
# }

# # Optional: small delay after S3 policy/ownership controls
# resource "time_sleep" "after_bucket_policy" {
#   depends_on = [
#     aws_s3_bucket_policy.alb_logs,
#     aws_s3_bucket_ownership_controls.logs,
#     aws_s3_bucket_public_access_block.logs
#   ]
#   create_duration = "60s"
# }

# resource "null_resource" "enable_alb_access_logs" {
#   depends_on = [
#     time_sleep.after_bucket_policy,
#     aws_lb.this
#   ]

#   triggers = {
#     lb_arn   = aws_lb.this.arn
#     bucket   = local.logs_bucket_name
#     prefix   = local.logs_prefix
#   }

#   provisioner "local-exec" {
#     command = <<-EOC
#       set -euo pipefail
#       aws elbv2 modify-load-balancer-attributes \
#         --load-balancer-arn "${self.triggers.lb_arn}" \
#         --attributes \
#           Key=access_logs.s3.enabled,Value=true \
#           Key=access_logs.s3.bucket,Value="${self.triggers.bucket}" \
#           Key=access_logs.s3.prefix,Value="${self.triggers.prefix}"
#     EOC
#   }
# }
