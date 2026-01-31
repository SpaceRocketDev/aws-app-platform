# output "alb_dns_name" {
#   value = aws_lb.this.dns_name
# }



# output "arn_suffix" {
#   value = aws_lb.this.arn_suffix
# }

# output "alias_zones_debug" {
#   value = local.alias_zones
# }

# output "alb_arn" {
#   value = aws_lb.this.arn
# }

output "alb_sg_id" {
  description = "Security group id of the ALB"
  value       = aws_security_group.alb.id
}


output "alb_arn" {
  description = "ARN of the load balancer."
  value       = aws_lb.this.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix for use with CloudWatch metrics."
  value       = aws_lb.this.arn_suffix
}

output "dns_name" {
  description = "DNS name of the load balancer."
  value       = aws_lb.this.dns_name
}

output "load_balancer_arn" {
  description = "ARN of the load balancer associated with the HTTPS listener."
  value       = aws_lb_listener.default_app_443.load_balancer_arn
}

output "cert_arn" {
  description = "ARN of the TLS certificate associated with the HTTPS listener."
  value       = aws_lb_listener.default_app_443.certificate_arn
}

output "ssl_policy" {
  description = "SSL policy applied to the HTTPS listener."
  value       = aws_lb_listener.default_app_443.ssl_policy
}

output "listener_443_arn" {
  description = "ARN of the HTTPS (443) listener."
  value       = aws_lb_listener.default_app_443.arn
}

