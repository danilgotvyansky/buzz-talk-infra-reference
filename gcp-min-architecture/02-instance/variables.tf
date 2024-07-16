variable "instance_template_name" {
  description = "Name for the instance template"
  type        = string
}

variable "instance_group_name" {
  description = "Name for the managed instance group"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID from network module"
  type        = string
}

variable "startup_script_path" {
  description = "Path to the startup script file"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
}

variable "autoscaling_conf" {
  description = "Autoscaling policy for instances in group"
  type = object({
    mode            = string
    max_replicas    = number
    min_replicas    = number
    cooldown_period = number

    cpu_utilization = object({
      target = number
    })

    scale_in_control = object({
      max_scaled_in_replicas = object({
        fixed = number
      })
      time_window_sec = number
    })
  })
}

variable "service_account_email" {
  description = "An email of the Compute Engine default service account"
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