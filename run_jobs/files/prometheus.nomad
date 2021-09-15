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

  - job_name: nomad
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
    static_configs:
    - targets: ['nb.skyer9.pe.kr:4646']

  - job_name: hello_world
    metrics_path: /actuator/prometheus
    static_configs:
    - targets: ['nb.skyer9.pe.kr:8080']

  - job_name: traefik

    metrics_path: /metrics
    consul_sd_configs:
    - server: '{{ env "attr.unique.network.ip-address" }}:8500'
      services: ['traefik-api']
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

        tags = [
          "traefik.enable=true",
          "traefik.tcp.routers.prometheus.entrypoints=prometheus",
          "traefik.tcp.routers.prometheus.rule=HostSNI(`*`)"
        ]

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
