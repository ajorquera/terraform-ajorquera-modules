# ------------------------------------------------------------------------------
# STATIC IP 
# ------------------------------------------------------------------------------
resource "google_compute_global_address" "default" {
  name = "global-ip"
}

# ------------------------------------------------------------------------------
# CREATE A GOOGLE COMPUTE MANAGED CERTIFICATE
# ------------------------------------------------------------------------------
resource "google_compute_managed_ssl_certificate" "default" {
  provider = google-beta

  name = "cdn-managed-certificate"

  managed {
    domains = [var.domain]
  }
}


# ------------------------------------------------------------------------------
# LOAD BALANCER
# ------------------------------------------------------------------------------

resource "google_compute_backend_bucket" "default" {
  name        = "${var.bucket_name}-backend-bucket"
  bucket_name = var.bucket_name
  enable_cdn  = true
  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = 3600
    default_ttl       = 3600
    max_ttl           = 86400
    negative_caching  = true
    serve_while_stale = 86400
  }
}

resource "google_compute_url_map" "default" {
  name            = "cdn-url-map"
  default_service = google_compute_backend_bucket.default.self_link
  project         = var.project_id
}


resource "google_compute_target_https_proxy" "default" {
  name             = "cdn-https-proxy"
  url_map          = google_compute_url_map.default.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.default.self_link]
  project          = var.project_id
}


resource "google_compute_global_forwarding_rule" "default" {
  name       = "cdn-global-forwarding-https-rule"
  target     = google_compute_target_https_proxy.default.self_link
  ip_address = google_compute_global_address.default.address
  port_range = "443"
  project    = var.project_id
}


# ------------------------------------------------------------------------------
# CREATE DNS RECORDS
# ------------------------------------------------------------------------------

resource "google_dns_managed_zone" "default" {
  name     = "prod-zone"
  dns_name = var.domain
}

resource "google_dns_record_set" "default" {
  managed_zone = google_dns_managed_zone.default.name
  name         = "${var.domain}."
  type         = "A"
  ttl          = 3600
  rrdatas      = [google_compute_global_address.default.address]
  project      = var.project_id
}
