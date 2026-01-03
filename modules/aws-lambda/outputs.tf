output "function_url" {
  description = "The HTTPS URL of the Lambda function alias"
  value       = aws_lambda_function_url.alias_url.function_url
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda_function_container_image.lambda_function_name
}

output "role_name" {
  description = "Name of the IAM role associated with the Lambda function"
  value       = module.lambda_function_container_image.lambda_role_name
}

output "codeDeploy_role_name" {
  description = "Name of the IAM role associated with CodeDeploy"
  value       = aws_iam_role_policy.codedeploy_access.role
}