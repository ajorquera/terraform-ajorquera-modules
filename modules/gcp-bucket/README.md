# GCP Bucket Terraform Module

This Terraform module provisions and manages Google Cloud Storage buckets in a Google Cloud Platform (GCP) project. It supports configuring bucket properties such as lifecycle rules, versioning, and access control.

## Features

- Creates and configures GCP storage buckets.
- Supports bucket versioning for object recovery.
- Configures lifecycle rules for automatic object management.
- Allows setting custom IAM policies for bucket access.

## Requirements

- **Terraform**: Version 1.10.5 or higher.
- **Google Cloud Provider**: Ensure you have the `google` and `google-beta` providers configured.
- **GCP Project**: A valid GCP project ID is required.

## Usage

```hcl
module "gcp_bucket" {
  source = "./gcp-bucket"

  bucket_name   = "my-bucket"
  project_id = "your-gcp-project-id"
  location      = "US"
  versioning    = true

  lifecycle_rules = [
    {
      action = {
        type = "Delete"
      }
      condition = {
        age = 30
      }
    }
  ]
}
```

## Resources Created
This module creates the following resources:

google_storage_bucket: Creates the GCP storage bucket.
google_storage_bucket_iam_member: Configures IAM policies for the bucket.
google_storage_bucket_object: Manages objects within the bucket.
Lifecycle Rules
You can define lifecycle rules to automatically manage objects in the bucket. For example:

```
lifecycle_rules = [
  {
    action = {
      type = "Delete"
    }
    condition = {
      age = 30
    }
  }
]
```

This rule deletes objects older than 30 days.

License
This module is licensed under the MIT License. See the LICENSE file for details.

Contributing
Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

Author
This module is maintained by [Your Name or Organization]. ```
