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

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      perl -pi -e 's/backend "local" {}/backend "s3" {\n    bucket = "${aws_s3_bucket.default.bucket}"\n    key    = "${var.bucket_key}"\n    region = "${var.aws_region}"\n  }/g' main.tf
    EOT
    
    working_dir = path.root
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      perl -i -0pe 's/backend "s3" \{[^}]*\}/backend "local" {}/gs' main.tf
    EOT
    
    working_dir = path.root
  }
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
    region = "${var.aws_region}"
  EOT
  filename = "config.s3.tfbackend"
}