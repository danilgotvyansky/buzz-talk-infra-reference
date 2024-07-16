instance_template_name = "instance-template-1"
instance_group_name    = "instance-group-1"

autoscaling_conf = {
  mode            = "ON"
  max_replicas    = 2
  min_replicas    = 1
  cooldown_period = 360

  cpu_utilization = {
    target = 0.99
  }

  scale_in_control = {
    max_scaled_in_replicas = {
      fixed = 1
    }
    time_window_sec = 600
  }
}