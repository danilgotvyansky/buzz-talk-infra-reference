include {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../03-load-balancer"
}

dependency "network" {
  config_path = "../01-network"
}

dependency "instance" {
  config_path = "../02-instance"
}

inputs = {
  managed_instance_group_instance_group = dependency.instance.outputs.managed_instance_group_instance_group
  traffic_lb_ip                         = dependency.network.outputs.traffic_lb_ip
}