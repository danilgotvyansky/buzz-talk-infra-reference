output "backend_service_id" {
  value = google_compute_backend_service.application_be.id
  description = "ID of the backend service"
}

output "url_map_id" {
  value = google_compute_url_map.application_lb.id
  description = "ID of the URL map"
}

output "http_proxy_id" {
  value = google_compute_target_http_proxy.application_lb_target_proxy.id
  description = "ID of the HTTP proxy"
}

output "global_forwarding_rule_id" {
  value = google_compute_global_forwarding_rule.application_traffic_fe.id
  description = "ID of the global forwarding rule"
}