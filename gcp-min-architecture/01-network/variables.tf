variable "network_name" {
  description = "Name for the VPC network"
  type        = string
}

variable "subnetwork_name" {
  description = "Name for the private subnet"
  type        = string
}

variable "traffic_lb_ip_name" {
  description = "Name for the Traffic Load Balancer IP address"
  type        = string
}

variable "healthcheck_firewall_name" {
  description = "Name for the firewall rule to allow health check"
  type        = string
}

variable "region" {
  description = "Region for the resources"
  type        = string
}

variable "project_id" {
  description = "GCP project id"
  type        = string
}