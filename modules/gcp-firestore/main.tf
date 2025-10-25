
resource "google_project_service" "default" {
  for_each = toset([
    "firestore.googleapis.com",
    "identitytoolkit.googleapis.com",
    "cloudapis.googleapis.com",
    "storage.googleapis.com",
    "serviceusage.googleapis.com",
    "firebaserules.googleapis.com",
    "firebasestorage.googleapis.com",
  ])

  service            = each.key
  disable_on_destroy = false
  project            = var.project_id
}

// AUTHENTICATION ----------------------------------------------------------------------------------------
resource "google_identity_platform_config" "default" {
  provider = google-beta
  project  = var.project_id

  depends_on = [google_project_service.default]

  multi_tenant {
    allow_tenants = false
  }

  sign_in {
    anonymous {
      enabled = false
    }
    email {
      enabled = true
    }
    phone_number {
      enabled = false
    }
  }

  authorized_domains = flatten([
    "localhost",
    "${var.project_id}.web.app",
    var.domain == "" ? [] : [var.domain],
  ])
}

// FIRESTORE DATABASE ----------------------------------------------------------------------------------------

resource "google_firebaserules_ruleset" "firestore" {
  project = var.project_id
  source {
    files {
      name    = "firestore.rules"
      content = file("firestore.rules")
    }
  }

  depends_on = [google_app_engine_application.default]
}

resource "google_firebaserules_release" "firestore" {
  name         = "cloud.firestore" # must be cloud.firestore
  ruleset_name = google_firebaserules_ruleset.firestore.name
  project      = var.project_id

  # Wait for Firestore to be provisioned before releasing the ruleset.
  depends_on = [google_app_engine_application.default]

  lifecycle {
    replace_triggered_by = [
      google_firebaserules_ruleset.firestore
    ]
  }
}

// STORAGE ----------------------------------------------------------------------------------------

/** 
 * App Engine creates a default bucket when you create an app. This bucket provides the first 5GB of storage 
 * for free and includes a free quota for Cloud Storage I/O operations. 
*/
resource "google_app_engine_application" "default" {

  project       = var.project_id
  location_id   = var.gcp_region
  database_type = "CLOUD_FIRESTORE"

  depends_on = [
    google_project_service.default
  ]
}

resource "google_firebase_storage_bucket" "default-bucket" {
  provider  = google-beta
  project   = var.project_id
  bucket_id = google_app_engine_application.default.default_bucket
}

resource "google_firebaserules_ruleset" "storage" {
  provider = google-beta
  project  = var.project_id
  source {
    files {
      name    = "storage.rules"
      content = file("storage.rules")
    }
  }

  depends_on = [google_firebase_storage_bucket.default-bucket]
}

resource "google_firebaserules_release" "default-bucket" {
  name         = "firebase.storage/${google_app_engine_application.default.default_bucket}"
  ruleset_name = "projects/${var.project_id}/rulesets/${google_firebaserules_ruleset.storage.name}"
  project      = var.project_id

  lifecycle {
    replace_triggered_by = [
      google_firebaserules_ruleset.storage
    ]
  }
}
