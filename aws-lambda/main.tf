terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

module "lambda_function_container_image" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = var.function_name
  aws_region    = var.aws_region 
  description   = var.description

  create_package = false

  image_uri    = module.docker_image.image_uri
  package_type = "Image"
  architectures = ["arm64"] 
}

module "docker_image" {
  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  create_ecr_repo = true
  ecr_repo        = var.ecr_repo

  use_image_tag = true
  image_tag     = var.image_tag

  source_path     = "context"
  ecr_repo_lifecycle_policy = {
    rules = [
      {
        rule_priority = 1
        description   = "Keep only the latest ${var.max_images} images"
        selection = {
          tag_status   = "any"
          count_type   = "imageCountMoreThan"
          count_number = var.max_images
        }
        action = {
          type = "expire"
        }
      }
    ]
  }
}

module "alias_refresh" {
  source = "terraform-aws-modules/lambda/aws//modules/alias"

  name          = "live"
  function_name = module.lambda_function.lambda_function_name
  function_version = module.lambda_function.lambda_function_version
}

module "deploy" {
  source = "terraform-aws-modules/lambda/aws//modules/deploy"

  alias_name    = module.alias_refresh.lambda_alias_name
  function_name = module.lambda_function.lambda_function_name

  target_version = module.lambda_function.lambda_function_version

  create_app = true
  app_name   = "${var.function_name}-codedeploy-app"

  create_deployment_group = true

  create_deployment          = true
  run_deployment             = true
  wait_deployment_completion = true

  deployment_config_name      = var.code_deploy_config_name

  triggers = var.sns_notify_topic_arn != "" ? {
    failed = {
      events     = ["DeploymentFailure"]
      name       = "DeploymentFailure"
      target_arn = var.sns_notify_topic_arn
    }
  } : {}
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