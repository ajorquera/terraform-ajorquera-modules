terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"
    }
  }
}

provider "google-beta" {
  project               = var.project_id
  region                = var.gcp_region
  billing_project       = var.project_id
  user_project_override = true
}

