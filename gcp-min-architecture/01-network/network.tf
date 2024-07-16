resource "google_compute_network" "application_vpc" {
  name                    = var.network_name
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = var.subnetwork_name
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.application_vpc.id
  region        = var.region
}

resource "google_compute_global_address" "traffic_lb_ip" {
  name = var.traffic_lb_ip_name
  address_type = "EXTERNAL"
}

resource "google_compute_firewall" "application_allow_healthcheck" {
  name    = var.healthcheck_firewall_name
  network = google_compute_network.application_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  direction     = "INGRESS"
  priority      = 1000
  target_tags   = ["allow-health-check"]
}

# Other firewall configurations are exluded due to security reasons
