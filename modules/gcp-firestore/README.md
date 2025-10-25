# Firestore Terraform Module

This Terraform module provisions and configures a Firestore database along with associated Firebase services in a Google Cloud Platform (GCP) project. It includes resources for Firestore, Firebase Storage, Firebase Rules.

> **Note:** App Engine is provisioned to take advantage of a free tier bucket of 5gb. 

## Features

- Enables required GCP services for Firestore and Firebase.
- Configures Firestore database with custom security rules.
- Sets up Firebase Storage with default buckets and rules.
- Integrates with App Engine for Firebase hosting.

## Requirements

- **Terraform**: Version 1.10.5 or higher.
- **Google Cloud Provider**: Ensure you have the `google` and `google-beta` providers configured.
- **GCP Project**: A valid GCP project ID is required.

### Optional params
- **domain**: domain to be added for the google identity platform for authorized domains
- **gcp_region:** GCP region for resources. Default is `us-central`

## Usage

```hcl
module "firestore" {
  source = "https://github.com/ajorquera/terraform-modules/dcp-firestore.git"

  project_id = "your-gcp-project-id"
  
  # optional
  gcp_region     = "us-central"
  domain         = "your-custom-domain.com"
}
```

## Outputs
- **firebase_sdk_config:** It outputs the necesary credentials for the [firebase sdk](https://firebase.google.com/docs/reference/js/app.md#initializeapp)