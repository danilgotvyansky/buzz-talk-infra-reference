terraform {
  source = "../01-network"
}

include {
  path = find_in_parent_folders("env.hcl")
}
