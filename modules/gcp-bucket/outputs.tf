output "bucket_url" {
  value       = google_storage_bucket.default.url
  description = "Url of the bucket"
}
