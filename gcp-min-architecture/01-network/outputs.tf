output "application_allow_healthcheck_name" {
  description = "The name of the ingress firewall allowing healthcheck from a balancer"
  value = google_compute_firewall.application_allow_healthcheck.name
}

output "traffic_lb_ip" {
  description = "Static global external IP address for application load balancer."
  value = google_compute_global_address.traffic_lb_ip.address
}

output "application_vpc_id" {
    value = google_compute_network.application_vpc.id
    description = "The ID of the Private VPC network"
}

output "private_subnet_id" {
  value = google_compute_subnetwork.private_subnet.id
  description = "The ID of the private subnet"
}

output "private_subnet_cidr" {
  value = google_compute_subnetwork.private_subnet.ip_cidr_range
  description = "The IP CIDR range of the private subnet"
}