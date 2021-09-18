job "prometheus" {
  datacenters = ["dc1"]

  group "prometheus" {
    count = 1

    network {
      port "prometheus_ui" {}
    }

    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus:v2.25.0"
        ports = ["prometheus_ui"]

        auth_soft_fail = true

        args = [
          "--config.file=/etc/prometheus/config/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--web.listen-address=0.0.0.0:${NOMAD_PORT_prometheus_ui}",
          "--web.console.libraries=/usr/share/prometheus/console_libraries",
          "--web.console.templates=/usr/share/prometheus/consoles",
        ]

        volumes = [
          "local/config:/etc/prometheus/config",
        ]
      }

      template {
        data = <<EOH
---
global:
  scrape_interval:     1s
  evaluation_interval: 1s

scrape_configs:

  - job_name: prometheus
    metrics_path: /metrics
    static_configs:
    - targets: ['nb.skyer9.pe.kr:9090']

  - job_name: nomad
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
    static_configs:
    - targets: ['nb.skyer9.pe.kr:4646']

  - job_name: ecr_hello_world
    metrics_path: /actuator/prometheus
    static_configs:
    - targets: ['nb.skyer9.pe.kr:9999']

  - job_name: haproxy_exporter
    static_configs:
      - targets: [{{ range service "haproxy-exporter" }}'nb.skyer9.pe.kr:{{ .Port }}',{{ end }}]
EOH

        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/config/prometheus.yml"
      }

      resources {
        cpu    = 100
        memory = 256
      }

      service {
        name = "prometheus"
        port = "prometheus_ui"

        check {
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
