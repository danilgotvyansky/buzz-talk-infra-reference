variable "region" {
  description = "Region for the resources"
  type        = string
}

variable "project_id" {
  description = "GCP project id"
  type        = string
}

variable "healthcheck_name" {
  description = "Name for the health check"
  type        = string
}

variable "backend_name" {
  description = "Name for the backend service"
  type        = string
}

variable "url_map_name" {
  description = "Name for the URL map"
  type        = string
}

variable "http_proxy_name" {
  description = "Name for the HTTP proxy"
  type        = string
}

variable "forwarding_rule_name" {
  description = "Name for the forwarding rule"
  type        = string
}

variable "managed_instance_group_instance_group" {
  description = "'instance_group' value of the managed instance group"
  type        = string
}

variable "traffic_lb_ip" {
  description = "Static global external IP address for application load balancer."
}