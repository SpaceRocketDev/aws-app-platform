resource "aws_ecs_cluster" "ecs_app_cluster" {
  name = var.ecs_cluster_config.cluster_name_override != "" ? var.ecs_cluster_config.cluster_name_override : "${var.ecs_cluster_config.name_prefix}-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "default" {
  cluster_name          = aws_ecs_cluster.ecs_app_cluster.name
  capacity_providers    = ["FARGATE"] # You can add "FARGATE_SPOT" if desired
  default_capacity_provider_strategy {
    base              = 1
    weight            = 1
    capacity_provider = "FARGATE"
  }
}

# ECS Execution Role (used by ECS to pull images, manage logs, etc.)
resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.ecs_cluster_config.name_prefix}-ecs-execution-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_execution_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_policy" "ssm_params_policy" {
  name = "${var.ecs_cluster_config.env}-${var.ecs_cluster_config.project}-ssm-params-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect  = "Allow"
      Action  = ["ssm:GetParameters"]
      Resource = [
        for prefix in var.ecs_cluster_config.ssm_secret_path_prefixes :
        "arn:aws:ssm:${var.ecs_cluster_config.aws_region}:${var.ecs_cluster_config.account_id}:parameter${prefix}/*"
      ]
    }]
  })
}


resource "aws_iam_role_policy_attachment" "ssm_params_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ssm_params_policy.arn
}

resource "aws_iam_policy" "ecs_execution_ssm_access" {
  name = "${var.ecs_cluster_config.env}-${var.ecs_cluster_config.project}-ecs-execution-ssm"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid     = "AllowSSMReadForECSExecution"
      Effect  = "Allow"
      Action  = ["ssm:GetParameters", "ssm:GetParameter", "ssm:GetParametersByPath"]
      Resource = [
        for prefix in var.ecs_cluster_config.ssm_secret_path_prefixes :
        "arn:aws:ssm:${var.ecs_cluster_config.aws_region}:${var.ecs_cluster_config.account_id}:parameter${prefix}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_ssm_access" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_ssm_access.arn
}

# Allow ECS execution role to read Secrets Manager for RDS cluster secrets in this account and region
resource "aws_iam_policy" "ecs_exec_secretsmanager" {
  name = "${var.ecs_cluster_config.env}-${var.ecs_cluster_config.project}-ecs-exec-secrets"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "GetRdsClusterSecrets",
        Effect: "Allow",
        Action: ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
        Resource: "arn:aws:secretsmanager:${var.ecs_cluster_config.aws_region}:${var.ecs_cluster_config.account_id}:secret:rds!*"
      },
      {
        Sid: "KmsDecryptForSecretsManagerOnly",
        Effect: "Allow",
        Action: ["kms:Decrypt"],
        Resource: "*",
        Condition: {
          StringEquals: { "kms:ViaService": "secretsmanager.${var.ecs_cluster_config.aws_region}.amazonaws.com" }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec_secretsmanager_attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_exec_secretsmanager.arn
}

# ECS Task Role (used by your app containers at runtime)
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.ecs_cluster_config.name_prefix}-ecs-task-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
