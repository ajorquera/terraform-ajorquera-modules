provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_firestore_database" "default" {
  name     = "default"
  location = var.region
  project  = var.project_id
}

resource "google_firestore_index" "index" {
  project     = var.project_id
  collection  = var.collection
  fields {
    field_path = var.field_path
    order      = var.order
  }
}

resource "google_firestore_document" "document" {
  project     = var.project_id
  collection  = var.collection
  document_id = var.document_id
  fields      = var.fields
}
