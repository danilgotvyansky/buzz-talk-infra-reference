//noinspection MissingProperty
resource "grafana_rule_group" "scaling_1m" {
  name             = "scaling_1m"
  folder_uid       = "adhk1921q7h1ca"
  interval_seconds = 60
  disable_provenance = true

  rule {
    name      = var.app_scaling_rule_name
    condition = "scale_trigger"

    data {
      ref_id = "total_mem"

      relative_time_range {
        from = 60
        to   = 0
      }

      datasource_uid = var.prometheus_nc_datasource_uid
      model          = jsonencode({
          "datasource": {
              "type": "prometheus",
              "uid": var.prometheus_nc_datasource_uid
          },
          "editorMode": "code",
          "expr": "sum by(instance_id, public_ip) (node_memory_MemTotal_bytes{})  / 1024 / 1024",
          "instant": true,
          "intervalMs": 1000,
          "legendFormat": "{{public__ip}} {{instance_id}}",
          "maxDataPoints": 43200,
          "range": false,
          "refId": "total_mem"
      })
    }
    data {
      ref_id = "app_containers_mem_limits"

      relative_time_range {
        from = 60
        to   = 0
      }

      datasource_uid = var.prometheus_nc_datasource_uid
      model          = jsonencode({
          "datasource": {
              "type": "prometheus",
              "uid": var.prometheus_nc_datasource_uid
          },
          "disableTextWrap": false,
          "editorMode": "code",
          "exemplar": false,
          "expr": "avg by(container_label_com_docker_swarm_service_name, instance_id, public_ip) (container_spec_memory_limit_bytes{container_label_com_docker_swarm_service_name=~\"backend|frontend\"}) / 1024 / 1024",
          "format": "time_series",
          "fullMetaSearch": false,
          "includeNullMetadata": true,
          "instant": true,
          "interval": "",
          "intervalMs": 15000,
          "legendFormat": "{{container_label_com_docker_swarm_service_name}} - {{instance}} {{public_ip}} ({{instance_id}}) ",
          "maxDataPoints": 43200,
          "range": false,
          "refId": "app_containers_mem_limits",
          "useBackend": false
      })
    }
    data {
      ref_id = "sum_infra_mem_reservations"

      relative_time_range {
        from = 60
        to   = 0
      }

      datasource_uid = var.prometheus_nc_datasource_uid
      model          = jsonencode({
        "datasource": {
            "type": "prometheus",
            "uid": var.prometheus_nc_datasource_uid
        },
        "editorMode": "code",
        "exemplar": false,
        "expr": "106000000 / 1024 / 1024",
        "format": "time_series",
        "instant": true,
        "interval": "",
        "intervalMs": 15000,
        "legendFormat": "__auto",
        "maxDataPoints": 43200,
        "range": false,
        "refId": "sum_infra_mem_reservations"
      })
    }
    data {
      ref_id = "avg_app_mem_by_name"

      relative_time_range {
        from = 900
        to   = 0
      }

      datasource_uid = var.prometheus_nc_datasource_uid
      model          = jsonencode({
        "datasource": {
            "type": "prometheus",
            "uid": var.prometheus_nc_datasource_uid
        },
        "disableTextWrap": false,
        "editorMode": "code",
        "exemplar": false,
        "expr": "avg by(container_label_com_docker_swarm_service_name, instance_id, public_ip) (container_memory_usage_bytes{container_label_com_docker_swarm_service_name=~\"backend|frontend\"} / container_spec_memory_limit_bytes{container_label_com_docker_swarm_service_name=~\"backend|frontend\"})",
        "format": "time_series",
        "fullMetaSearch": false,
        "includeNullMetadata": true,
        "instant": false,
        "intervalMs": 1000,
        "legendFormat": "__auto",
        "maxDataPoints": 43200,
        "range": true,
        "refId": "avg_app_mem_by_name",
        "useBackend": false
      })
    }
    data {
      ref_id = "sum_app_containers_mem_limits"

      relative_time_range {
        from = 60
        to   = 0
      }

      datasource_uid = var.prometheus_nc_datasource_uid
      model          = jsonencode({
        "datasource": {
            "type": "prometheus",
            "uid": var.prometheus_nc_datasource_uid
        },
        "disableTextWrap": false,
        "editorMode": "code",
        "expr": "sum by(instance_id, public_ip) (container_spec_memory_limit_bytes{container_label_com_docker_swarm_service_name=~\"backend|frontend\"})  / 1024 / 1024",
        "fullMetaSearch": false,
        "includeNullMetadata": true,
        "instant": true,
        "intervalMs": 1000,
        "legendFormat": "__auto",
        "maxDataPoints": 43200,
        "range": false,
        "refId": "sum_app_containers_mem_limits",
        "useBackend": false
      })
    }
    data {
      ref_id = "total_cpu"

      relative_time_range {
        from = 60
        to   = 0
      }

      datasource_uid = var.prometheus_nc_datasource_uid
      model          = jsonencode({
        "datasource": {
            "type": "prometheus",
            "uid": var.prometheus_nc_datasource_uid
        },
        "editorMode": "code",
        # Hardcoded to 0.25 since e2-micro has 2-vCPU worth of physical 0.25 CPU
        "expr": "0.25",
        "instant": true,
        "intervalMs": 1000,
        "legendFormat": "__auto",
        "maxDataPoints": 43200,
        "range": false,
        "refId": "total_cpu"
      })
    }
    data {
      ref_id = "app_containers_cpu_limits"

      relative_time_range {
        from = 60
        to   = 0
      }

      datasource_uid = var.prometheus_nc_datasource_uid
      model          = jsonencode({
        "datasource": {
            "type": "prometheus",
            "uid": var.prometheus_nc_datasource_uid
        },
        "editorMode": "code",
        "expr": "avg by(container_label_com_docker_swarm_service_name, instance_id, public_ip) (container_spec_cpu_quota{container_label_com_docker_swarm_service_name=~\"backend|frontend\"} / container_spec_cpu_period{container_label_com_docker_swarm_service_name=~\"backend|frontend\"})",
        "instant": true,
        "intervalMs": 1000,
        "legendFormat": "__auto",
        "maxDataPoints": 43200,
        "range": false,
        "refId": "app_containers_cpu_limits"
      })
    }
    data {
      ref_id = "avg_app_cpu_by_name"

      relative_time_range {
        from = 900
        to   = 0
      }

      datasource_uid = var.prometheus_nc_datasource_uid
      model          = jsonencode({
        "datasource": {
            "type": "prometheus",
            "uid": var.prometheus_nc_datasource_uid
        },
        "editorMode": "code",
        "expr": "avg by(container_label_com_docker_swarm_service_name, instance_id, public_ip) (rate(container_cpu_usage_seconds_total{container_label_com_docker_swarm_service_name=~\"backend|frontend\"}[1m]) / ignoring (cpu, mode)\r\n(container_spec_cpu_quota{container_label_com_docker_swarm_service_name=~\"backend|frontend\"} / container_spec_cpu_period{container_label_com_docker_swarm_service_name=~\"backend|frontend\"}))",
        "instant": false,
        "intervalMs": 1000,
        "legendFormat": "__auto",
        "maxDataPoints": 43200,
        "range": true,
        "refId": "avg_app_cpu_by_name"
      })
    }
    data {
      ref_id = "sum_containers_cpu_limits"

      relative_time_range {
        from = 60
        to   = 0
      }

      datasource_uid = var.prometheus_nc_datasource_uid
      model          = jsonencode({
          "datasource": {
              "type": "prometheus",
              "uid": var.prometheus_nc_datasource_uid
          },
          "editorMode": "code",
          "expr": "sum by(instance_id, public_ip) (container_spec_cpu_quota / container_spec_cpu_period)",
          "instant": true,
          "intervalMs": 1000,
          "legendFormat": "__auto",
          "maxDataPoints": 43200,
          "range": false,
          "refId": "sum_containers_cpu_limits"
      })
    }
    data {
      ref_id = "app_active_containers"

      relative_time_range {
        from = 60
        to   = 0
      }

      datasource_uid = var.prometheus_nc_datasource_uid
      model          = jsonencode({
        "datasource": {
            "type": "prometheus",
            "uid": var.prometheus_nc_datasource_uid
        },
        "editorMode": "code",
        "expr": "count by(container_label_com_docker_swarm_service_name, instance_id, public_ip) (container_tasks_state{state=\"running\", container_label_com_docker_swarm_service_name=~\"backend|frontend\"})",
        "instant": true,
        "intervalMs": 1000,
        "legendFormat": "__auto",
        "maxDataPoints": 43200,
        "range": false,
        "refId": "app_active_containers"
      })
    }
    data {
      ref_id = "app_containers_desired"

      relative_time_range {
        from = 60
        to   = 0
      }

      datasource_uid = var.prometheus_nc_datasource_uid
      model = jsonencode({
        datasource = {
          type = "prometheus"
          uid  = var.prometheus_nc_datasource_uid
        }
        editorMode       = "code"
        exemplar         = false
        expr             = "label_replace(vector(${var.backend_containers_desired}), \"container_label_com_docker_swarm_service_name\", \"backend\", \"__name__\", \".*\") or label_replace(vector(${var.frontend_containers_desired}), \"container_label_com_docker_swarm_service_name\", \"frontend\", \"__name__\", \".*\")"
        instant          = true
        intervalMs       = 1000
        legendFormat     = "__auto"
        maxDataPoints    = 43200
        range            = false
        refId            = "app_containers_desired"
      })
    }
    data {
      ref_id = "can_we_scale_mem"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        "conditions": [
            {
                "evaluator": {
                    "params": [
                        0,
                        0
                    ],
                    "type": "gt"
                },
                "operator": {
                    "type": "and"
                },
                "query": {
                    "params": []
                },
                "reducer": {
                    "params": [],
                    "type": "avg"
                },
                "type": "query"
            }
        ],
        "datasource": {
            "name": "Expression",
            "type": "__expr__",
            "uid": "__expr__"
        },
        /*
        Calculate how many containers can be added on the instance based on the limits and reservations depending on the
        case. Round the number to the nearest lowest one.
        */
        "expression": "floor(($total_mem - ($sum_app_containers_mem_limits + $sum_infra_mem_reservations)) / $app_containers_mem_limits)",
        "intervalMs": 1000,
        "maxDataPoints": 43200,
        "refId": "can_we_scale_mem",
        "type": "math"
      })
    }
    data {
      ref_id = "mem_threshold"

      relative_time_range {
        from = 900
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        "conditions": [
            {
                "evaluator": {
                    "params": [
                        0.85,
                        0
                    ],
                    "type": "gt"
                },
                "operator": {
                    "type": "and"
                },
                "query": {
                    "params": []
                },
                "reducer": {
                    "params": [],
                    "type": "avg"
                },
                "type": "query"
            }
        ],
        "datasource": {
            "name": "Expression",
            "type": "__expr__",
            "uid": "__expr__"
        },
        "expression": "avg_time_mem",
        "intervalMs": 1000,
        "maxDataPoints": 43200,
        "refId": "mem_threshold",
        "type": "threshold"
      })
    }
    data {
      ref_id = "can_we_scale_cpu"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        "conditions": [
            {
                "evaluator": {
                    "params": [
                        0,
                        0
                    ],
                    "type": "gt"
                },
                "operator": {
                    "type": "and"
                },
                "query": {
                    "params": []
                },
                "reducer": {
                    "params": [],
                    "type": "avg"
                },
                "type": "query"
            }
        ],
        "datasource": {
            "name": "Expression",
            "type": "__expr__",
            "uid": "__expr__"
        },
        /*
        Calculate how many containers can be added on the instance based on the limits. Round the number to the nearest
        lowest one.
        */
        "expression": "floor(($total_cpu - $sum_containers_cpu_limits) / $app_containers_cpu_limits)",
        "intervalMs": 1000,
        "maxDataPoints": 43200,
        "refId": "can_we_scale_cpu",
        "type": "math"
      })
    }
    data {
      ref_id = "app_new_containers_number"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        "conditions": [
            {
                "evaluator": {
                    "params": [
                        0,
                        0
                    ],
                    "type": "gt"
                },
                "operator": {
                    "type": "and"
                },
                "query": {
                    "params": []
                },
                "reducer": {
                    "params": [],
                    "type": "avg"
                },
                "type": "query"
            }
        ],
        "datasource": {
            "name": "Expression",
            "type": "__expr__",
            "uid": "__expr__"
        },
        "expression": var.app_new_containers_number_expression,
        "intervalMs": 1000,
        "maxDataPoints": 43200,
        "refId": "app_new_containers_number",
        "type": "math"
      })
    }
    data {
      ref_id = "cpu_threshold"

      relative_time_range {
        from = 900
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        "conditions": [
            {
                "evaluator": {
                    "params": [
                        0.7,
                        0
                    ],
                    "type": "gt"
                },
                "operator": {
                    "type": "and"
                },
                "query": {
                    "params": []
                },
                "reducer": {
                    "params": [],
                    "type": "avg"
                },
                "type": "query"
            }
        ],
        "datasource": {
            "name": "Expression",
            "type": "__expr__",
            "uid": "__expr__"
        },
        "expression": "avg_time_cpu",
        "intervalMs": 1000,
        "maxDataPoints": 43200,
        "refId": "cpu_threshold",
        "type": "threshold"
      })
    }
    data {
      ref_id = "avg_time_mem"

      relative_time_range {
        from = 900
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        "conditions": [
            {
                "evaluator": {
                    "params": [
                        0,
                        0
                    ],
                    "type": "gt"
                },
                "operator": {
                    "type": "and"
                },
                "query": {
                    "params": []
                },
                "reducer": {
                    "params": [],
                    "type": "avg"
                },
                "type": "query"
            }
        ],
        "datasource": {
            "name": "Expression",
            "type": "__expr__",
            "uid": "__expr__"
        },
        "expression": "avg_app_mem_by_name",
        "intervalMs": 1000,
        "maxDataPoints": 43200,
        "reducer": "mean",
        "refId": "avg_time_mem",
        "settings": {
            "mode": "dropNN"
        },
        "type": "reduce"
      })
    }
    data {
      ref_id = "avg_time_cpu"

      relative_time_range {
        from = 900
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        "conditions": [
            {
                "evaluator": {
                    "params": [
                        0,
                        0
                    ],
                    "type": "gt"
                },
                "operator": {
                    "type": "and"
                },
                "query": {
                    "params": []
                },
                "reducer": {
                    "params": [],
                    "type": "avg"
                },
                "type": "query"
            }
        ],
        "datasource": {
            "name": "Expression",
            "type": "__expr__",
            "uid": "__expr__"
        },
        "expression": "avg_app_cpu_by_name",
        "intervalMs": 1000,
        "maxDataPoints": 43200,
        "reducer": "mean",
        "refId": "avg_time_cpu",
        "settings": {
            "mode": "dropNN"
        },
        "type": "reduce"
      })
    }
    data {
      ref_id = "scale_trigger"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        "conditions": [
            {
                "evaluator": {
                    "params": [
                        0,
                        0
                    ],
                    "type": "gt"
                },
                "operator": {
                    "type": "and"
                },
                "query": {
                    "params": []
                },
                "reducer": {
                    "params": [],
                    "type": "avg"
                },
                "type": "query"
            }
        ],
        "datasource": {
            "name": "Expression",
            "type": "__expr__",
            "uid": "__expr__"
        },
        "expression": var.scale_trigger_expression,
        "intervalMs": 1000,
        "maxDataPoints": 43200,
        "refId": "scale_trigger",
        "type": "math"
      })
    }

    no_data_state  = "KeepLast"
    exec_err_state = "KeepLast"
    for            = "1m"
    annotations = {
      __dashboardUid__ = "ddhk3a9mpumtcb"
      __panelId__      = "75"
      summary          = "Scaling ${var.scaling_direction_go_tmpl} service {{ $labels.container_label_com_docker_swarm_service_name }} on instance {{ $labels.public_ip }}\nOld containers count: {{ $values.app_active_containers }}\nNew containers count: {{ $values.app_new_containers_number }}"
    }
    labels = {
      Env            = "gcp"
      Infra          = "buzztalk-min"
      contact        = "discord"
      scalecontainer = "true"
      scaling        = var.scaling_direction_go_tmpl
      tf_provisioned = "true"
    }
    is_paused = false
  }
}
