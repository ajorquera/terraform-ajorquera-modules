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

module "tfstate_backend" {
  source = "../../aws-tfstate"
  bucket_prefix = "aws-tfstate"
  aws_region   = local.aws_region
  force_destroy = true
}
