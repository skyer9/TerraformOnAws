job "grafana" {
  datacenters = ["dc1"]

  group "grafana" {
    count = 1

    network {
      port "grafana_ui" {}
    }

    volume "grafana" {
      type   = "host"
      source = "grafana"
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana:7.4.2"
        ports = ["grafana_ui"]

        # host 로 설정했으므로 127.0.0.1 는 호스트를 가르킨다.
        network_mode = "host"

        auth_soft_fail = true

        volumes = [
          "local/datasources:/etc/grafana/provisioning/datasources",
          "local/dashboards:/etc/grafana/provisioning/dashboards",
        ]
      }

      env {
        GF_INSTALL_PLUGINS         = "grafana-clock-panel,grafana-piechart-panel,natel-discrete-panel"
        GF_AUTH_ANONYMOUS_ENABLED  = "true"
        GF_AUTH_ANONYMOUS_ORG_ROLE = "Editor"
        GF_SERVER_HTTP_PORT        = "${NOMAD_PORT_grafana_ui}"
      }

      template {
        data = <<EOH
apiVersion: 1
datasources:
- name: Prometheus
  type: prometheus
  access: proxy
  url: http://{{ range $i, $s := service "prometheus" }}{{ if eq $i 0 }}{{.Address}}:{{.Port}}{{end}}{{end}}
  isDefault: true
  version: 1
  editable: true
EOH

        destination = "local/datasources/prometheus.yaml"
      }

      template {
        data = <<EOH
apiVersion: 1
providers:
- name: Nomad Autoscaler
  folder: Nomad
  folderUid: nomad
  type: file
  disableDeletion: true
  editable: false
  allowUiUpdates: false
  options:
    path: /var/lib/grafana/dashboards
EOH

        destination = "local/dashboards/nomad-autoscaler.yaml"
      }

      volume_mount {
        volume      = "grafana"
        destination = "/var/lib/grafana"
      }

      resources {
        cpu    = 100
        memory = 64
      }

      service {
        name = "grafana"
        port = "grafana_ui"

        check {
          type     = "http"
          path     = "/api/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}