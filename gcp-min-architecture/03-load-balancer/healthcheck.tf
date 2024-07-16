resource "google_compute_health_check" "http_basic_healthcheck" {
  name               = var.healthcheck_name
  check_interval_sec = 5
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 2
  http_health_check {
    port         = 80
    request_path = "/"
  }
}