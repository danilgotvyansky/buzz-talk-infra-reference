resource "google_compute_region_instance_group_manager" "managed_instance_group" {
  name                             = var.instance_group_name
  base_instance_name               = var.instance_group_name
  region                           = var.region
  distribution_policy_zones = [
    "${var.region}-c",
    "${var.region}-b",
    "${var.region}-a"
  ]
  distribution_policy_target_shape = "EVEN"

  update_policy {
    type                         = "PROACTIVE"
    minimal_action               = "REPLACE"
    instance_redistribution_type = "PROACTIVE"
    max_unavailable_fixed        = 3
    max_surge_fixed              = 3
  }

  version {
    instance_template = google_compute_instance_template.instance_template_1.self_link
  }

  target_pools = []

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_region_autoscaler" "managed_autoscaler" {
  name     = "${var.instance_group_name}-autoscaler"
  region   = var.region
  target   = google_compute_region_instance_group_manager.managed_instance_group.id

  autoscaling_policy {
    mode            = var.autoscaling_conf.mode
    max_replicas    = var.autoscaling_conf.max_replicas
    min_replicas    = var.autoscaling_conf.min_replicas
    cooldown_period = var.autoscaling_conf.cooldown_period

    cpu_utilization {
      target = var.autoscaling_conf.cpu_utilization.target
    }

    scale_in_control {
      max_scaled_in_replicas {
        fixed = var.autoscaling_conf.scale_in_control.max_scaled_in_replicas.fixed
      }
      time_window_sec = var.autoscaling_conf.scale_in_control.time_window_sec
    }
  }
}
