output "prometheus_service_account_email" {
  value = google_service_account.prometheus.email
}

output "prometheus_service_account_key" {
  value     = base64decode(google_service_account_key.prometheus_key.private_key)
  sensitive = true
}

resource "local_file" "prometheus_service_account_key" {
  content  = base64decode(google_service_account_key.prometheus_key.private_key)
  filename = "../../04-monitoring/iam/prometheus_sa_key.json"
}

output "stackdriver_exporter_service_account_email" {
  value = google_service_account.prometheus.email
}

output "stackdriver_exporter_service_account_key" {
  value     = base64decode(google_service_account_key.stackdriver_exporter_key.private_key)
  sensitive = true
}

resource "local_file" "stackdriver_exporter_service_account_key" {
  content  = base64decode(google_service_account_key.stackdriver_exporter_key.private_key)
  filename = "../../04-monitoring/iam/stackdriver_exporter_sa_key.json"
}