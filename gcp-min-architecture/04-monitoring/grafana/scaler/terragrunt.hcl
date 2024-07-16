include {
  path = find_in_parent_folders("grafana.hcl")
}

terraform {
  source = "../../../04-monitoring/grafana/scaler"
}