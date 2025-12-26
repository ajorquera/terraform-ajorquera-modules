terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "local" {}
}

locals {
  aws_region = "us-east-1" 
}

provider "aws" {
  region = local.aws_region 
}

module "aws-lambda" {
  source = "../../aws-lambda"

  aws_region             = local.aws_region   
  ecr_repo               = "my-hello-world-repo"
  function_name          = "hello-world"
  deployment_config_name = "CodeDeployDefault.LambdaLinear10PercentEvery1Minute"
  sns_notify_topic_arn   = "arn:aws:sns:us-east-1:658068096501:any-notification"
}