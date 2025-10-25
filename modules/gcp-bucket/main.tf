resource "google_storage_bucket" "default" {
  name                        = var.bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"

  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}


resource "google_storage_bucket_iam_member" "default" {
  bucket = google_storage_bucket.default.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_object" "index_page" {
  name    = "index-page"
  bucket  = google_storage_bucket.default.name
  content = <<-EOT
    <html>
        <body>
            <h1>Congratulations on setting up Google Cloud CDN with Storage backend!</h1>
        </body>
    </html>
  EOT
}

resource "google_storage_bucket_object" "error_page" {
  name    = "404-page"
  bucket  = google_storage_bucket.default.name
  content = <<-EOT
    <html>
        <body>
            <h1>404 Error: Object you are looking for is no longer available!</h1>
        </body>
    </html>
  EOT
}
