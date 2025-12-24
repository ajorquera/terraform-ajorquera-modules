variable "aws_region" {
    description = "The AWS region where the Lambda function will be deployed"
    type        = string
}

variable "function_name" {
    description = "The name of the Lambda function"
    type        = string
}

variable "ecr_repo" {
    description = "The name of the ECR repository to store the Docker image"
    type        = string
}

variable "image_tag" {
    description = "The tag for the Docker image"
    type        = string
    default     = "latest"
}

variable "max_images" {
    description = "The maximum number of images to retain in the ECR repository"
    type        = number
    default     = 5
}

variable "code_deploy_config_name" {
    description = "The name of the CodeDeploy deployment configuration"
    type        = string
    default     = "CodeDeployDefault.LambdaAllAtOnce"
    validation {
        condition     = contains(["CodeDeployDefault.LambdaAllAtOnce", "CodeDeployDefault.LambdaLinear10PercentEvery1Minute", "CodeDeployDefault.LambdaLinear10PercentEvery2Minutes", "CodeDeployDefault.LambdaLinear10PercentEvery3Minutes", "CodeDeployDefault.LambdaLinear10PercentEvery10Minutes", "CodeDeployDefault.LambdaCanary10Percent5Minutes", "CodeDeployDefault.LambdaCanary10Percent10Minutes", "CodeDeployDefault.LambdaCanary10Percent15Minutes", "CodeDeployDefault.LambdaCanary10Percent30Minutes"], var.deployment_config_name)
        error_message = "The deployment_config_name must be one of the predefined CodeDeploy Lambda deployment configurations."
    }
}

variable "sns_notify_topic_arn" {
    description = "The ARN of the SNS topic to notify on deployment failures"
    type        = string
    default     = ""   
}