resource "aws_lb" "this" {
  #checkov:skip=CKV2_AWS_76:AWSManagedRulesKnownBadInputsRuleSet is configured in waf.tf; Checkov graph cannot trace count-indexed associations
  name               = var.alb_config.name_prefix
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.alb_config.lb_subnets[*].id
  enable_http2       = true
  ip_address_type    = "dualstack"

  enable_deletion_protection = var.alb_config.enable_deletion_protection

  drop_invalid_header_fields = true

  access_logs {
    enabled = true
    bucket  = aws_s3_bucket.logs["this"].id
    prefix  = var.alb_config.logs_prefix
  }

  depends_on = [
    aws_kms_key.alb_logs,
    aws_s3_bucket_policy.alb_logs,
    aws_s3_bucket_ownership_controls.logs,
    aws_s3_bucket_public_access_block.logs,
    aws_s3_bucket_server_side_encryption_configuration.logs
  ]
  
  tags = var.alb_config.common_tags
}

resource "aws_lb_listener" "default_80" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      status_code = "HTTP_301"
      protocol    = "HTTPS"
      port        = 443
    }
  }
}

resource "aws_lb_listener" "default_app_443" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.alb_config.lb_ssl_policy
  certificate_arn   = var.alb_config.main_cert_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access denied"
      status_code  = "403"
    }
  }
}
