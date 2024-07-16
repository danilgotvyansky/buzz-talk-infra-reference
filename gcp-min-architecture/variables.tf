variable "region" {
  description = "Region for the resources"
  type        = string
}

variable "project_id" {
  description = "GCP project id"
  type        = string
}

variable "grafana_url" {
  description = "URL of Grafana where scaler resides"
  type        = string
}

variable "grafana_token" {
  description = "Service account API token of Grafana where scaler resides"
  type        = string
  sensitive   = true
}