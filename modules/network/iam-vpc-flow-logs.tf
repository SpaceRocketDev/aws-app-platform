# Retrieves the AWS account ID at runtime
data "aws_caller_identity" "current" {}

# IAM role assumed by VPC Flow Logs service to publish flow logs to CloudWatch Logs
resource "aws_iam_role" "vpc_flow" {
  name = "${local.name_prefix}-vpc-flow-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "VpcFlowLogsTrust",
      Effect = "Allow",
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc-flow-role"
  })
}

# Inline policy allowing the VPC Flow Logs IAM role to write to the VPC flow log group
resource "aws_iam_role_policy" "vpc_flow" {
  name = "${local.name_prefix}-vpc-flow-policy"
  role = aws_iam_role.vpc_flow.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowWriteToLogGroup",
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = "${aws_cloudwatch_log_group.vpc_flow.arn}:*"
      }
    ]
  })
}
