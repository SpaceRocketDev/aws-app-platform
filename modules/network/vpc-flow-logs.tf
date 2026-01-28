# VPC Flow Logs (ALL traffic) delivered to CloudWatch Logs using the dedicated IAM role
resource "aws_flow_log" "this" {
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.vpc_flow.arn
  iam_role_arn             = aws_iam_role.vpc_flow.arn
  traffic_type             = "ALL"
  max_aggregation_interval = 60

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc-flow"
  })
}
