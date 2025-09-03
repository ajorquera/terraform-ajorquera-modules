# terraform-modules

## Firestore Module

This module allows you to create and manage Firestore resources using Terraform.

### Usage

```hcl
module "firestore" {
  source      = "./firestore"
  project_id  = "your-project-id"
  region      = "your-region"
  collection  = "your-collection"
  document_id = "your-document-id"
  fields      = {
    field1 = "value1"
    field2 = "value2"
  }
  field_path = "your-field-path"
  order      = "ASCENDING"
}
```
