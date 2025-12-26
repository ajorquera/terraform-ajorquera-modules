variable "git_commit" {
    description = "Git commit SHA for the Docker image metadata (optional)"
    type        = string
    default     = ""
}

variable "source_path" {
    description = "Path to the source code directory containing Dockerfile and application files"
    type        = string
    default     = "."
}

variable "aws_region" {
    description = "The AWS region where the Lambda function will be deployed"
    type        = string
}

variable "function_name" {
    description = "The name of the Lambda function"
    type        = string
}

variable "description" {
    description = "The description of the Lambda function"
    type        = string
    default     = "My Lambda function deployed via Terraform"
}

variable "ecr_repo" {
    description = "The name of the ECR repository to store the Docker image"
    type        = string
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
        condition     = contains([
            "CodeDeployDefault.LambdaAllAtOnce", 
            "CodeDeployDefault.LambdaLinear10PercentEvery1Minute", 
            "CodeDeployDefault.LambdaLinear10PercentEvery2Minutes", 
            "CodeDeployDefault.LambdaLinear10PercentEvery3Minutes",
            "CodeDeployDefault.LambdaLinear10PercentEvery10Minutes", 
            "CodeDeployDefault.LambdaCanary10Percent5Minutes", 
            "CodeDeployDefault.LambdaCanary10Percent10Minutes", 
            "CodeDeployDefault.LambdaCanary10Percent15Minutes", 
            "CodeDeployDefault.LambdaCanary10Percent30Minutes"
        ], var.code_deploy_config_name)
        error_message = "The deployment_config_name must be one of the predefined CodeDeploy Lambda deployment configurations."
    }
}

variable "sns_notify_topic_arn" {
    description = "The ARN of the SNS topic to notify on deployment failures"
    type        = string
    default     = ""   
}