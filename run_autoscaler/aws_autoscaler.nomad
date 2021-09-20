job "autoscaler" {
  datacenters = ["dc1"]

  group "autoscaler" {
    count = 1

    network {
      port "http" {}
    }

    task "autoscaler" {
      driver = "docker"
      config {
        image   = "hashicorp/nomad-autoscaler:0.3.3"
        ports = ["http"]

        auth_soft_fail = true

        command = "nomad-autoscaler"
        args = [
          "agent",
          "-config",
          "$${NOMAD_TASK_DIR}/config.hcl",
          "-http-bind-address",
          "0.0.0.0",
          "-http-bind-port",
          "$${NOMAD_PORT_http}",
          "-policy-dir",
          "$${NOMAD_TASK_DIR}/policies/",
        ]
      }

      template {
        data = <<EOF
nomad {
  address = "http://{{env "attr.unique.network.ip-address" }}:4646"
}

apm "prometheus" {
  driver = "prometheus"
  config = {
    address = "http://{{ range service "prometheus" }}{{ .Address }}:{{ .Port }}{{ end }}"
  }
}

# Datadog example template is below. In order to use the example config section
# you will need to remove the first line "#" comments as well as the golang
# template comment markers which are "- /*" and "*/".
#
# apm "datadog" {
#   driver = "datadog"
#   config = {
# {{- /* with secret "secret/autoscaler/datadog" }}
#     dd_api_key = "{{ .Data.data.api_key }}"
#     dd_app_key = "{{ .Data.data.app_key }}"
# {{ end */ -}}
#   }
# }

target "aws-asg" {
  driver = "aws-asg"
  config = {
    aws_region = "{{ $x := env "attr.platform.aws.placement.availability-zone" }}{{ $length := len $x |subtract 1 }}{{ slice $x 0 $length}}"
  }
}

strategy "target-value" {
  driver = "target-value"
}
EOF

        destination = "$${NOMAD_TASK_DIR}/config.hcl"
      }

      template {
        data = <<EOF
scaling "cluster_policy" {
  enabled = true
  min     = 1
  max     = 2
  policy {
    cooldown            = "2m"
    evaluation_interval = "1m"
    check "cpu_allocated_percentage" {
      source = "prometheus"
      query  = "sum(nomad_client_allocated_cpu*100/(nomad_client_unallocated_cpu+nomad_client_allocated_cpu))/count(nomad_client_allocated_cpu)"
      strategy "target-value" {
        target = 70
      }
    }
    # Datadog example
    # check "cpu_allocated_percentage" {
    #   source       = "datadog"
    #   query        = "avg:nomad.client.allocated.cpu{*}/(avg:nomad.client.unallocated.cpu{*}+avg:nomad.client.allocated.cpu{*})*100"
    #   query_window = "2m"
    #   strategy "target-value" {
    #     target = 70
    #   }
    # }

    check "mem_allocated_percentage" {
      source = "prometheus"
      query  = "sum(nomad_client_allocated_memory*100/(nomad_client_unallocated_memory+nomad_client_allocated_memory))/count(nomad_client_allocated_memory)"
      strategy "target-value" {
        target = 70
      }
    }
    # Datadog example
    # check "memory_allocated_percentage" {
    #   source       = "datadog"
    #   query        = "avg:nomad.client.allocated.memory{*}/(avg:nomad.client.unallocated.memory{*}+avg:nomad.client.allocated.memory{*})*100"
    #   query_window = "2m"
    #   strategy "target-value" {
    #     target = 70
    #   }
    # }

    target "aws-asg" {
      dry-run             = "false"
      aws_asg_name        = "my-nomad_client"         # client 노드 asg 이름
      node_class          = "hashistack"
      node_drain_deadline = "5m"
    }
  }
}
EOF

        destination = "$${NOMAD_TASK_DIR}/policies/hashistack.hcl"
      }

      resources {
        cpu    = 50
        memory = 128
      }

      service {
        name = "autoscaler"
        port = "http"
        check {
          type     = "http"
          path     = "/v1/health"
          interval = "5s"
          timeout  = "2s"
        }
      }
    }
  }
}
