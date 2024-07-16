include {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../02-instance"
}

dependency "network" {
  config_path = "../01-network"
}

inputs = {
  private_subnet_id = dependency.network.outputs.private_subnet_id
  startup_script_path = "${get_terragrunt_dir()}/../sources/startup-scripts/application-node-startup-script/startup.bash"
  ssh_public_key_path = "${get_terragrunt_dir()}/../../.ssh/deployment_key.pub"
}