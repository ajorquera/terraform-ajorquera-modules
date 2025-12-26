output "function_url" {
  description = "The HTTPS URL of the Lambda function alias"
  value       = aws_lambda_function_url.alias_url.function_url
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda_function_container_image.lambda_function_name
}

output "alias_name" {
  description = "Name of the Lambda alias"
  value       = module.alias_refresh.lambda_alias_name
}
