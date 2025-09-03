output "firestore_project_id" {
  description = "The ID of the project in which the Firestore resources are created."
  value       = var.project_id
}

output "firestore_region" {
  description = "The region in which the Firestore resources are created."
  value       = var.region
}

output "firestore_database_url" {
  description = "The URL of the Firestore database."
  value       = var.database_url
}
