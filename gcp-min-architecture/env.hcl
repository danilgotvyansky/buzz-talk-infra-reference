locals {
  bucket                = "buzz-talk"
  project               = "some-project-id"
  location              = "us-central1"
  service_account_email = "compute@some-project-id.iam.gserviceaccount.com"
}

inputs = {
  project_id            = local.project
  service_account_email = local.service_account_email
  region                = local.location
  grafana_url           = local.grafana_url
}

remote_state {
  backend = "gcs"

  config = {
    bucket   = local.bucket
    prefix   = "${basename(get_parent_terragrunt_dir())}/${path_relative_to_include()}"
    project  = local.project
    location = local.location
  }
}

generate "backend" {
  path      = "gen_backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "gcs" {
    bucket = "buzz-talk"
    prefix = "${basename(get_parent_terragrunt_dir())}/${path_relative_to_include()}"
  }
}
EOF
}

generate "provider" {
  path = "gen_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "google" {
  project = var.project_id
  region  = var.region
}
EOF
}

terraform {
  extra_arguments "common_var" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "destroy",
      "refresh",
      "apply-all",
      "destroy-all"
    ]

    optional_var_files = [
      "${get_terragrunt_dir()}/settings.tfvars",
    ]
  }
}