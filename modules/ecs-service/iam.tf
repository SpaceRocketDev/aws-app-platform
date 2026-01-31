#######################
# IAM Role for the Task
#######################
# IAM role assumed by the ECS task
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.ecs_service_config.task_name}-fargate-ecs-task-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_policy.json
}

data "aws_iam_policy_document" "ecs_task_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Optional policy allowing Secrets Manager access
resource "aws_iam_policy" "secrets_manager_policy" {
  name   = "${var.ecs_service_config.task_name}-secrets-manager-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "arn:aws:secretsmanager:${var.ecs_service_config.region}:${var.ecs_service_config.account_id}:secret:*"
    }
  ]
}
EOF
}

# Attaches Secrets Manager policy to the task role
resource "aws_iam_role_policy_attachment" "secrets_manager_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

# Policy enabling ECS Exec support
resource "aws_iam_policy" "ecs_exec_policy" {
  name   = "${var.ecs_service_config.task_name}-ecs-exec-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attaches ECS Exec policy to the task role
resource "aws_iam_role_policy_attachment" "ecs_exec_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}

# Optional policy allowing SQS access
resource "aws_iam_policy" "sqs_policy" {
  name   = "${var.ecs_service_config.task_name}-sqs-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:DeleteMessage",
        "sqs:ReceiveMessage",
        "sqs:SendMessage"
      ],
      "Resource": "arn:aws:sqs:${var.ecs_service_config.region}:${var.ecs_service_config.account_id}:*"
    }
  ]
}
EOF
}

# Attaches SQS policy to the task role
resource "aws_iam_role_policy_attachment" "sqs_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.sqs_policy.arn
}