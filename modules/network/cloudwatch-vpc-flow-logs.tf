# VPC Flow Logs log group (KMS-encrypted)
resource "aws_cloudwatch_log_group" "vpc_flow" { 
  name              = "/aws/vpc/flow-logs/${local.name_prefix}"
  retention_in_days = 365

  # use key_id instead of arn
  kms_key_id = aws_kms_key.cloudwatch_logs.arn

  depends_on = [
    aws_kms_key.cloudwatch_logs,
    aws_kms_alias.cloudwatch_logs
  ]

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpc-flow" })
}
