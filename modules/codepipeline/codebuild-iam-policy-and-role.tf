data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "code_build_role" {
  name               = "${local.task_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

data "aws_iam_policy_document" "codebuild_policy_document" {
  # CloudWatch Logs for CodeBuild build and deploy projects
  statement {
    sid    = "LogsWrite"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = [
      # log groups used by logs_config.cloudwatch_logs.group_name
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:${local.log_group_name}/codebuild/*",
      # required for stream creation and events
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:${local.log_group_name}/codebuild/*:log-stream:*"
    ]
  }

  statement {
    sid       = "Describe"
    effect    = "Allow"
    actions   = ["ec2:DescribeVpcs"]
    resources = ["*"]
  }

  statement {
    sid     = "S3ReadArtifacts"
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:GetObjectVersion", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }

  statement {
    sid     = "S3WriteArtifacts"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [data.aws_kms_alias.s3kmskey.target_key_arn]
    }
  }

  statement {
    sid       = "EcrAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "EcrRWSingleRepo"
    effect = "Allow"
    actions = [
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages"
    ]
    resources = [
      "arn:aws:ecr:${local.region}:${local.account_id}:repository/${local.image_repo}"
    ]
  }

  statement {
    sid       = "CodeStarUse"
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection", "codestar-connections:PassConnection"]
    resources = [aws_codestarconnections_connection.github_connection.arn]
  }

  statement {
    sid       = "KmsForArtifacts"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
    resources = [data.aws_kms_alias.s3kmskey.target_key_arn]
  }

  statement {
    sid     = "EcsRegisterDescribe"
    effect  = "Allow"
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:ListTaskDefinitions",
      "ecs:DescribeTaskDefinition"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "EcsUpdateSingleService"
    effect  = "Allow"
    actions = [
      "ecs:UpdateService",
      "ecs:DescribeServices",
      "ecs:ListTasks",
      "ecs:DescribeTasks"
    ]
    resources = [
      "arn:aws:ecs:${local.region}:${local.account_id}:service/${local.ecs_cluster_name}/${local.ecs_service_name}"
    ]
  }

  statement {
    sid     = "IamPassSpecificRoles"
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::${local.account_id}:role/${local.fargate_ecs_task_role}",
      local.fargate_ecs_execution_role
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    sid     = "CodeDeployEcs"
    effect  = "Allow"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetDeployment",
      "codedeploy:RegisterApplicationRevision",
      "codedeploy:GetDeploymentConfig"
    ]
    resources = ["*"]
    condition {
      test     = "StringEqualsIfExists"
      variable = "codedeploy:ApplicationName"
      values   = [coalesce(local.codedeploy_app, local.task_name)]
    }
  }
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  role   = aws_iam_role.code_build_role.name
  policy = data.aws_iam_policy_document.codebuild_policy_document.json
}
