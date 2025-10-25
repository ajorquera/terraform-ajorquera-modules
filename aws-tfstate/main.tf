terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

resource "aws_s3_bucket" "default" {
  bucket = "${var.bucket_prefix}-${var.bucket_name}"
  force_destroy = var.force_destroy
  object_lock_enabled = true
}

resource "aws_s3_bucket_versioning" "default" {
  bucket = aws_s3_bucket.default.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "local_file" "default" {
  content = <<-EOT
    bucket = "${aws_s3_bucket.default.bucket}" 
    key    = "${var.bucket_key}"
  EOT
  filename = "config.s3.tfbackend"

  provisioner "local-exec" {
    command = <<-EOT
      perl -pi -e 's/backend "local" {}/backend "s3" {\n    bucket = "${aws_s3_bucket.default.bucket}"\n    key    = "${var.bucket_key}"\n  }/g' main.tf
    EOT
    
    working_dir = path.root
    
  }
}