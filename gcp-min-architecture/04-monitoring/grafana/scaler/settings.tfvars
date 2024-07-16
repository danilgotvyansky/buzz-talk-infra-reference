/*
Make sure to create WebHook contact point with details matching the one set for the proxy_container_scaler.py script and
a Notification policy matching label: scalecontainer = true routing to this contact point for the scaler to work properly
*/
app_scaling_rule_name        = "Containers scaling trigger"
backend_containers_desired   = 1 # per instance
frontend_containers_desired  = 1 # per instance
prometheus_nc_datasource_uid = "edgxebyr4thxca"

/*
The reference code below demonstrates the condition logic of the app_new_containers_number_expression Math expression:
app_new_containers_number = 0

# scaling up condition
if can_we_scale_cpu == True and can_we_scale_mem == True:
    if (cpu_threshold == True or mem_threshold == True) or (app_active_containers < app_containers_desired):
        app_new_containers_number = 1

# scaling down condition
if (cpu_threshold == False and mem_threshold == False) and (app_active_containers > app_containers_desired):
    app_new_containers_number = -1

app_new_containers_number = app_new_containers_number + app_active_containers

Explanation for the can_we_scale_cpu and can_we_scale_mem expression is in scaling_rule_group.tf itself.
*/
app_new_containers_number_expression = <<-EOT
(
  (
    ($can_we_scale_cpu >= 1 && $can_we_scale_mem >= 1)
    &&
    (($cpu_threshold >= 1 || $mem_threshold >= 1) || ($app_active_containers < $app_containers_desired))
  ) * 1
  +
  (
    ($cpu_threshold == 0 && $mem_threshold == 0)
    &&
    ($app_active_containers > $app_containers_desired)
  ) * -1
) + $app_active_containers
EOT

/*
Description for the scale_trigger Math expression below:
The reference code below demonstrates the condition logic of the scale_trigger_expression Math expression:
trigger_scale = false

if app_new_containers_number != app_containers_desired:
  if can_we_scale_cpu == True and can_we_scale_mem == True:
    trigger_scale = true

if app_new_containers_number != app_active_containers:
  trigger_scale = true
*/
scale_trigger_expression = <<-EOT
(
  ($app_new_containers_number != $app_containers_desired)
  &&
  ($can_we_scale_cpu >= 1 && $can_we_scale_mem >= 1)
)
||
($app_new_containers_number != $app_active_containers)
EOT

scaling_direction_go_tmpl = "{{ if gt $values.app_new_containers_number.Value $values.app_active_containers.Value }}up{{ else if gt $values.app_active_containers.Value $values.app_new_containers_number.Value }}down{{ else }}not_possible{{ end }}"