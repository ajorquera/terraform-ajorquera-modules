terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "local" {}
}

provider "aws" {
  region = local.aws_region 
}

module "aws-lambda" {
  source = "../../aws-lambda"
  aws_region = local.aws_region   
  ecr_repo   = "my-lambda-ecr-repo"
}