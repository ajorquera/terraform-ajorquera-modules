# AWS Lambda Container Image Module

A Terraform module for deploying AWS Lambda functions using container images with automated CI/CD capabilities via AWS CodeDeploy.

## Features

- 🐳 **Container-based Lambda**: Deploys Lambda functions using Docker container images
- 🏗️ **Automated ECR Management**: Creates and manages ECR repository with lifecycle policies
- 🚀 **CI/CD Integration**: Built-in AWS CodeDeploy for safe, gradual deployments
- 🔄 **Blue-Green Deployments**: Support for various deployment strategies (linear, canary, all-at-once)
- 🌐 **Function URL**: Automatic creation of Lambda Function URL with CORS support
- 📊 **Monitoring**: CloudWatch alarms for error tracking
- 🔔 **SNS Notifications**: Optional SNS notifications for deployment failures and errors
- 🏷️ **Git Integration**: Support for git commit SHA tagging
- 🗑️ **Image Lifecycle**: Configurable ECR image retention policy

## Architecture

This module creates the following resources:
- AWS Lambda function (container image)
- Amazon ECR repository with lifecycle policies
- Lambda function alias (`live`)
- Lambda Function URL with CORS configuration
- AWS CodeDeploy application and deployment group
- IAM roles and policies for CodeDeploy
- CloudWatch metric alarm (optional)
- SNS topic triggers (optional)

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- Docker installed (for building container images)
- A Dockerfile in your source directory

## Usage

### Basic Example

```hcl
module "aws-lambda" {
  source = "github.com/ajorquera/terraform-ajorquera-modules//aws-lambda"

  aws_region    = "us-east-1"
  ecr_repo      = "my-app-repo"
  function_name = "my-lambda-function"
}
```

### Complete Example with All Options

```hcl
module "aws-lambda" {
  source = "github.com/ajorquera/terraform-ajorquera-modules//aws-lambda"

  aws_region             = "us-east-1"
  function_name          = "hello-world"
  description            = "My Hello World Lambda function"
  ecr_repo               = "my-hello-world-repo"
  source_path            = "./src"
  git_commit             = "abc123def456"
  max_images             = 10
  deployment_config_name = "CodeDeployDefault.LambdaLinear10PercentEvery1Minute"
  sns_notify_topic_arn   = "arn:aws:sns:us-east-1:123456789012:lambda-alerts"
}
```

### Example with SNS Monitoring

```hcl
resource "aws_sns_topic" "lambda_alerts" {
  name = "lambda-deployment-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.lambda_alerts.arn
  protocol  = "email"
  endpoint  = "devops@example.com"
}

module "aws-lambda" {
  source = "github.com/ajorquera/terraform-ajorquera-modules//aws-lambda"

  aws_region           = "us-east-1"
  ecr_repo             = "my-app-repo"
  function_name        = "my-lambda"
  sns_notify_topic_arn = aws_sns_topic.lambda_alerts.arn
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | The AWS region where the Lambda function will be deployed | `string` | n/a | yes |
| function_name | The name of the Lambda function | `string` | n/a | yes |
| ecr_repo | The name of the ECR repository to store the Docker image | `string` | n/a | yes |
| description | The description of the Lambda function | `string` | `"My Lambda function deployed via Terraform"` | no |
| source_path | Path to the source code directory containing Dockerfile and application files | `string` | `"."` | no |
| git_commit | Git commit SHA for the Docker image metadata (enables versioned tags) | `string` | `""` | no |
| max_images | The maximum number of images to retain in the ECR repository | `number` | `5` | no |
| deployment_config_name | The name of the CodeDeploy deployment configuration | `string` | `"CodeDeployDefault.LambdaAllAtOnce"` | no |
| sns_notify_topic_arn | The ARN of the SNS topic to notify on deployment failures and errors | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| function_url | The HTTPS URL of the Lambda function alias |
| function_name | Name of the Lambda function |

## Deployment Strategies

The module supports the following AWS CodeDeploy deployment configurations:

| Configuration | Description |
|--------------|-------------|
| `CodeDeployDefault.LambdaAllAtOnce` | Shifts all traffic at once (default) |
| `CodeDeployDefault.LambdaLinear10PercentEvery1Minute` | Shifts 10% every minute |
| `CodeDeployDefault.LambdaLinear10PercentEvery2Minutes` | Shifts 10% every 2 minutes |
| `CodeDeployDefault.LambdaLinear10PercentEvery3Minutes` | Shifts 10% every 3 minutes |
| `CodeDeployDefault.LambdaLinear10PercentEvery10Minutes` | Shifts 10% every 10 minutes |
| `CodeDeployDefault.LambdaCanary10Percent5Minutes` | Shifts 10%, then remaining after 5 minutes |
| `CodeDeployDefault.LambdaCanary10Percent10Minutes` | Shifts 10%, then remaining after 10 minutes |
| `CodeDeployDefault.LambdaCanary10Percent15Minutes` | Shifts 10%, then remaining after 15 minutes |
| `CodeDeployDefault.LambdaCanary10Percent30Minutes` | Shifts 10%, then remaining after 30 minutes |

## Monitoring and Alerting

When `sns_notify_topic_arn` is provided, the module creates:
- **Deployment Failure Notifications**: SNS notifications for failed CodeDeploy deployments
- **Error Alarm**: CloudWatch alarm that triggers when Lambda function errors occur

## Image Lifecycle Management

The module automatically manages ECR image lifecycle:
- Keeps the most recent images (configurable via `max_images`)
- Automatically expires older images
- Supports both tagged and untagged images

When using `git_commit`, the module:
- Tags images with the commit SHA
- Also tags the same image as `latest`
- Enables image traceability back to source code

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 6.0 |
| docker | 3.6.2 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 6.0 |
| docker | 3.6.2 |

## Directory Structure

Your source directory should contain at minimum:
```
source_path/
├── Dockerfile
└── (your application code)
```

Example Dockerfile for Node.js:
```dockerfile
FROM public.ecr.aws/lambda/nodejs:20

COPY index.mjs ${LAMBDA_TASK_ROOT}
COPY package*.json ${LAMBDA_TASK_ROOT}

RUN npm ci --only=production

CMD [ "index.handler" ]
```

## Important Notes

1. **Architecture**: The Lambda function is configured for ARM64 architecture by default
2. **Alias Management**: The `live` alias version is ignored in lifecycle to prevent conflicts with CodeDeploy
3. **CORS**: The function URL is configured with permissive CORS settings - adjust as needed for production
4. **Deployment**: Set `wait_deployment_completion = false` to avoid Terraform waiting for gradual deployments
5. **Image Triggers**: The module rebuilds images when source files change (`.mjs`, `.js`, `.json`, `Dockerfile`)



