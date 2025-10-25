output "firebase_sdk_config" {
  description = "Firebase SDK config object"
  sensitive   = true
  value = {
    projectId     = var.project_id
    authDomain    = var.domain
    apiKey        = google_identity_platform_config.default.client[0].api_key
    storageBucket = "gs://${google_app_engine_application.default.default_bucket}"
  }
}
