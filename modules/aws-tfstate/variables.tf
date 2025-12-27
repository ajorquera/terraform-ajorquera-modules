variable "bucket_name" {
  type = string
  description = "The aws bucket where the state will be store"
  default = "terraform-states"
}

variable "bucket_prefix" {
  type = string
  description = "The prefix inside the bucket where the state will be store"
  default = "aws-tfstate"
}

variable "bucket_key" {
  type = string
  description = "The key inside the bucket where the state will be store"
  default = "terraform.tfstate"
}

variable "force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error."
  default     = false
}

variable "aws_region" {
  type        = string
  description = "The AWS region where the S3 bucket will be created."
  default     = "us-east-1"
}