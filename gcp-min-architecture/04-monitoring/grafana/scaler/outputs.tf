output "app_scaling_rule_name" {
  value = grafana_rule_group.scaling_1m.rule[0].name
  description = "App scaling rule name"
}

output "app_scaling_rule_uid" {
  value = grafana_rule_group.scaling_1m.rule[0].uid
  description = "App scaling rule UID"
}

output "scaling_1m_rule_group_name" {
  value = grafana_rule_group.scaling_1m.name
  description = "Scaling 1m rule group name"
}

output "folder_uid" {
  value = grafana_rule_group.scaling_1m.folder_uid
  description = "Folder where scaling rule group resides"
}

