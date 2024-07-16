output "instance_template_id" {
  value = google_compute_instance_template.instance_template_1.id
  description = "ID of the instance template"
}

output "managed_instance_group_instance_group" {
  value = google_compute_region_instance_group_manager.managed_instance_group.instance_group
  description = "'instance_group' value of the managed instance group"
}