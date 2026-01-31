output "tg_arn" {
  value = aws_lb_target_group.this[0].arn
}

output "tg_name" {
  value = aws_lb_target_group.this[0].name
}
