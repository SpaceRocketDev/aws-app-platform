output "alb_arn" {
  description = "ALB ARN"
  value       = module.alb.alb_arn
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix used for CloudWatch metrics"
  value       = module.alb.alb_arn_suffix
}

output "alb_listener_443_arn" {
  description = "HTTPS (443) listener ARN for the ALB"
  value       = module.alb.load_balancer_arn
}

output "lb_ssl_policy" {
  description = "SSL policy applied to the ALB HTTPS listener"
  value       = module.alb.ssl_policy
}

output "cert_arn" {
  description = "ACM certificate ARN used by the ALB HTTPS listener"
  value       = module.alb.cert_arn
}

output "alb" {
  description = "Application Load Balancer outputs"
  value = {
    alb_arn              = module.alb.alb_arn
    alb_arn_suffix       = module.alb.alb_arn_suffix
    alb_listener_443_arn = module.alb.load_balancer_arn
    lb_ssl_policy        = module.alb.ssl_policy
    cert_arn             = module.alb.cert_arn
  }
}


