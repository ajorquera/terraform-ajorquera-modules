terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "local" {}
}

variable "aws_region" {}

module "tfstate_backend" {
  source = "../../aws-tfstate"
  bucket_prefix = "lgntd-2"
}
