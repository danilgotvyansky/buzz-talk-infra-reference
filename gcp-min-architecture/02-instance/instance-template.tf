data "local_file" "startup_script" {
  filename = var.startup_script_path
}

data "local_file" "ssh_public_key" {
  filename = var.ssh_public_key_path
}

resource "google_compute_instance_template" "instance_template_1" {
  name                = var.instance_template_name
  machine_type        = "e2-micro"
  can_ip_forward      = false
  instance_description = var.instance_template_name
  tags                = ["http-server", "https-server", "lb-health-check", "allow-health-check"]

  metadata = {
    startup-script = data.local_file.startup_script.content
    ssh-keys       = "deploy:${data.local_file.ssh_public_key.content}"
  }

  network_interface {
    subnetwork = var.private_subnet_id
    access_config {
      network_tier = "PREMIUM"
    }
  }

  disk {
    source_image = "projects/ubuntu-os-cloud/global/images/ubuntu-2310-mantic-amd64-v20240110"
    auto_delete  = true
    boot         = true
    disk_size_gb = 10
    disk_type    = "pd-standard"
  }

  service_account {
    email  = var.service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = false
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  scheduling {
    on_host_maintenance         = "TERMINATE"
    automatic_restart           = false
    preemptible                 = true
    provisioning_model          = "SPOT"
    instance_termination_action = "REPLACE"
  }

  lifecycle {
    ignore_changes = all
  }
}
