output "tfstate_path" {
  description = "The path to the terraform state file in S3"
  value = "s3://${aws_s3_bucket.default.bucket}/${var.bucket_key}"
}

output "bucket_name" {
  description = "The name of the S3 bucket created for storing terraform state"
  value       = aws_s3_bucket.default.bucket
}

output "bucket_key" {
  description = "The key inside the bucket where the state will be stored"
  value = "${var.bucket_key}"
}
