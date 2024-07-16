variable "region" {
  description = "Region for the resources"
  type        = string
}

variable "project_id" {
  description = "GCP project id"
  type        = string
}

variable "prometheus_account_id" {
  description = "Service account identifier"
  type        = string
}

variable "prometheus_display_name" {
  description = "Service account display name"
  type        = string
}

variable "stackdriver_exporter_account_id" {
  description = "Service account identifier"
  type        = string
}

variable "stackdriver_exporter_display_name" {
  description = "Service account display name"
  type        = string
}