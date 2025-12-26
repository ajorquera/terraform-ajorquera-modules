# terraform-modules

## AWS tfstate Backend
This directory contains Terraform configuration files to set up terraform tfstate backend in an AWS S3 bucket. Check [here](./aws-tfstate/) for more information

## Publishing a new version

To publish a new version of a Terraform module:

1. **Make your changes** and commit them to the repository
2. **Tag the commit** with a semantic version:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   ```
3. **Push the tag** to the remote repository:
   ```bash
   git push origin v1.0.0
   ```

### Version Format
Use semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backwards compatible)
- **PATCH**: Bug fixes (backwards compatible)

### Using the Module
Reference a specific version in your Terraform configuration:
```hcl
module "example" {
  source = "git::https://github.com/username/terraform-ajorquera-modules.git//module-name?ref=v1.0.0"
}
```
