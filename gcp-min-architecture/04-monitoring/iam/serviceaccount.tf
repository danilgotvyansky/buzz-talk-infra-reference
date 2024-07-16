resource "google_service_account" "prometheus" {
  account_id   = var.prometheus_account_id
  display_name = var.prometheus_display_name
}

resource "google_project_iam_member" "prometheus_compute_viewer" {
  project = var.project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.prometheus.email}"
}

resource "google_service_account_key" "prometheus_key" {
  service_account_id = google_service_account.prometheus.name
}

resource "google_service_account" "stackdriver_exporter" {
  account_id   = var.stackdriver_exporter_account_id
  display_name = var.stackdriver_exporter_display_name
}

resource "google_project_iam_member" "stackdriver_exporter_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.stackdriver_exporter.email}"
}

resource "google_service_account_key" "stackdriver_exporter_key" {
  service_account_id = google_service_account.stackdriver_exporter.name
}