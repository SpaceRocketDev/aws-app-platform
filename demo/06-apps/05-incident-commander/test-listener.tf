# HTTPS test listener used for CodeDeploy blue green test traffic
resource "aws_lb_listener" "test_8080" {
  load_balancer_arn = local.alb.alb_arn
  port              = 8443
  protocol          = "HTTPS"

  # Use the same TLS policy you set in alb
  ssl_policy      = local.alb.lb_ssl_policy
  certificate_arn = local.alb.cert_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "test-listener"
    }
  }
}
