resource "google_compute_backend_service" "application_be" {
  name                            = var.backend_name
  protocol                        = "HTTP"
  port_name                       = "http"
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  locality_lb_policy              = "ROUND_ROBIN"
  enable_cdn                      = false
  timeout_sec                     = 30
  connection_draining_timeout_sec = 300
  health_checks = [
    google_compute_health_check.http_basic_healthcheck.self_link
  ]

  backend {
    group                = var.managed_instance_group_instance_group
    balancing_mode       = "UTILIZATION"
    capacity_scaler      = 1
    max_utilization      = 0.8
  }
}

resource "google_compute_url_map" "application_lb" {
  name            = var.url_map_name
  default_service = google_compute_backend_service.application_be.self_link
}

resource "google_compute_target_http_proxy" "application_lb_target_proxy" {
  name    = var.http_proxy_name
  url_map = google_compute_url_map.application_lb.self_link
}

resource "google_compute_global_forwarding_rule" "application_traffic_fe" {
  name                  = var.forwarding_rule_name
  target                = google_compute_target_http_proxy.application_lb_target_proxy.self_link
  port_range            = "80"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = var.traffic_lb_ip
}
