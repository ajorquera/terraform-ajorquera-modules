# AWS tfstate Backend
This directory contains Terraform configuration files to set up an AWS S3 bucket. Check [here](https://developer.hashicorp.com/terraform/language/backend/s3) for more information about S3 backend for Terraform.  

> This module doesnt use dynamo table for state locking. It uses the new native S3 object locking feature.

## Prerequisites
- An AWS account with appropriate permissions to create S3 buckets.
- Terraform
- AWS CLI configured with your credentials.

### AWS permissions
Make sure the AWS user or role you are using has the following permissions:
- `s3:ListBucket`
- `s3:PutObject`
- `s3:GetObject`
- `s3:DeleteObject`
- `s3:CreateBucket`
- `s3:PutBucketVersioning`
- `s3:PutBucketObjectLockConfiguration`

## Variables
The following variables are used in the Terraform configuration:

- `bucket_name`: The name of the S3 bucket to be created (optional). `terraform-states` as default.
- `bucket_prefix`: The prefix for the S3 bucket name to ensure uniqueness. **Required**
- `bucket_key`: The key (path) within the S3 bucket where the Terraform state file will be stored.`terraform.tfstate` as default.
- `force_destroy`: A boolean to indicate whether to force destroy the bucket even if it contains objects. Default is `false`.

## Usage

In your `main.tf` file, include the module as follows:
```
module "aws_tfstate" {
  source = "ajorquera/terraform-ajorquera-modules/aws-tfstate"
  bucket_prefix = "lgntd-2"
}
```

Once you apply this module the first time, an S3 bucket will be created. You can then configure your Terraform backend to use this S3 bucket by updating your `main.tf` file as follows:

```
terraform {
  backend "s3" {
    bucket = "<your-bucket-name>"
    key    = "path/to/your/terraform.tfstate"
    region = "<your-aws-region>"
  }
}
```

A file named config.s3.tfbackend will be created with the backend configuration. You can use this file to initialize your Terraform project with the S3 backend.

```
terraform init -migrate-state -backend-config=config.s3.tfbackend
```