terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Or use data.aws_region.current.name
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_ecr_authorization_token" "token" {
  registry_id = data.aws_caller_identity.current.account_id
}

locals {
  ecr_registry = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.region}.amazonaws.com"
}

provider "docker" {
  registry_auth {
    address  = local.ecr_registry
    username = "AWS"
    password = data.aws_ecr_authorization_token.token.password
  }
}


module "lambda_function_container_image" {
  source = "terraform-aws-modules/lambda/aws"

  function_name  = var.function_name
  description    = var.description
  publish        = true
  create_package = false
  package_type   = "Image"
  architectures  = ["arm64"] 
  image_uri      = module.docker_image.image_uri
}

module "docker_image" {
  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  create_ecr_repo = true
  ecr_repo        = var.ecr_repo
  ecr_force_delete = true

  use_image_tag = var.git_commit != "" ? true : false
  image_tag     = var.git_commit != "" ? var.git_commit : null
  image_tag_mutability = "MUTABLE"
  keep_remotely = true

  source_path     = var.source_path
  docker_file_path = "${var.source_path}/Dockerfile"
  
  build_args = var.git_commit != "" ? {
    GIT_COMMIT = var.git_commit
  } : {}
  
  triggers = {
    dir_sha = sha256(join("", [for f in fileset(var.source_path, "{*.mjs,*.js,*.json,Dockerfile}") : filesha256("${var.source_path}/${f}")]))
  }

  ecr_repo_lifecycle_policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep only the latest ${var.max_images} images",
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": ${var.max_images}
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOF

}

resource "terraform_data" "tag_latest" {
  count = var.git_commit != "" ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      MANIFEST=$(aws ecr batch-get-image --region ${var.aws_region} --repository-name ${var.ecr_repo} --image-ids imageTag=${var.git_commit} --query 'images[0].imageManifest' --output text)
      aws ecr put-image --region ${var.aws_region} --repository-name ${var.ecr_repo} --image-tag latest --image-manifest "$MANIFEST" 2>/dev/null || true
    EOT
  }

  triggers_replace = {
    image_uri = module.docker_image.image_uri
  }
  
  depends_on = [module.docker_image]
}

resource "aws_lambda_alias" "live" {
  name             = "live"
  function_name    = module.lambda_function_container_image.lambda_function_name
  function_version = module.lambda_function_container_image.lambda_function_version

  lifecycle {
    ignore_changes = [function_version]
  }
}

resource "aws_lambda_function_url" "alias_url" {
  function_name      = module.lambda_function_container_image.lambda_function_name
  qualifier          = aws_lambda_alias.live.name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}

module "deploy" {
  source = "terraform-aws-modules/lambda/aws//modules/deploy"

  alias_name     = aws_lambda_alias.live.name
  function_name  = module.lambda_function_container_image.lambda_function_name
  target_version = module.lambda_function_container_image.lambda_function_version

  app_name                = "${var.function_name}-codedeploy-app"
  deployment_group_name   = "${var.function_name}-deployment-group"
  
  create_app                 = true
  create_deployment_group    = true
  create_codedeploy_role     = true
  attach_triggers_policy     = var.sns_notify_topic_arn != "" ? true : false
  
  create_deployment          = true
  run_deployment             = true
  wait_deployment_completion = false

  deployment_config_name = var.deployment_config_name
  
  aws_cli_command = "AWS_REGION=${var.aws_region} aws"

  triggers = var.sns_notify_topic_arn != "" ? {
    failed = {
      events     = ["DeploymentFailure"]
      name       = "DeploymentFailure"
      target_arn = var.sns_notify_topic_arn
    }
  } : {}
  
  depends_on = [aws_lambda_alias.live]
}

resource "aws_iam_role_policy" "default" {
  name = "${var.function_name}-codedeploy-access"
  role = "${var.function_name}-codedeploy-app-codedeploy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetAlias",
          "lambda:UpdateAlias",
          "lambda:PublishVersion"
        ]
        Resource = [
          module.lambda_function_container_image.lambda_function_arn,
          "${module.lambda_function_container_image.lambda_function_arn}:*"
        ]
      }
    ]
  })
  
  depends_on = [module.deploy]
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count = var.sns_notify_topic_arn != "" ? 1 : 0

  alarm_name          = "${var.function_name}-errors-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Triggers when Lambda function ${var.function_name} encounters errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_function_container_image.lambda_function_name
  }

  alarm_actions = [var.sns_notify_topic_arn]
}