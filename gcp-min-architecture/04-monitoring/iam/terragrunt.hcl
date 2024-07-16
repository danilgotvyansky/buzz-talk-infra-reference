include {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../04-monitoring/iam"
}