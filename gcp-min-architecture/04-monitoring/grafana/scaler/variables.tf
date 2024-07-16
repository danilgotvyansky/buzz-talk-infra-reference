variable "grafana_url" {
  description = "URL of Grafana where scaler resides"
  type        = string
}

variable "grafana_token" {
  description = "Service account API token of Grafana where scaler resides"
  type        = string
  sensitive   = true
}

variable "app_scaling_rule_name" {
  description = "Alert rule for scaling app containers name"
  type        = string
}

variable "backend_containers_desired" {
  description = "Amount of desired backend service containers per instance"
  type        = number
}

variable "frontend_containers_desired" {
  description = "Amount of desired frontend service containers per instance"
  type        = number
}

variable "app_new_containers_number_expression" {
  description = "High-end Math expression for handling scaling conditions based on numerous factors"
  type        = string
}

variable "scale_trigger_expression" {
  description = "High-end Math expression for handling scaling triggering based on numerous factors"
  type        = string
}

variable "scaling_direction_go_tmpl" {
  description = "Go template syntax for representing scaling direction"
  type        = string
}

variable "prometheus_nc_datasource_uid" {
  description = "Datasource UID for Prometheus hosted on Namecheap server (default Grafana datasource)"
  type        = string
}