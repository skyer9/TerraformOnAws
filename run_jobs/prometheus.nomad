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

        # host 로 설정했으므로 127.0.0.1 는 호스트를 가르킨다.
        network_mode = "host"

        auth_soft_fail = true

        args = [
          "--config.file=/etc/prometheus/config/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--web.listen-address=0.0.0.0:${NOMAD_PORT_prometheus_ui}",
          "--web.console.libraries=/usr/share/prometheus/console_libraries",
          "--web.console.templates=/usr/share/prometheus/consoles",
          # for Thanos
          # "--storage.tsdb.max-block-duration=2h",
          # "--storage.tsdb.min-block-duration=2h",
        ]

        volumes = [
          "local/config:/etc/prometheus/config",
        ]
      }

      template {
        data = <<EOH
---
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:

  - job_name: prometheus
    metrics_path: /metrics
    consul_sd_configs:
    - server: '127.0.0.1:8500'
      services: ['prometheus']

  - job_name: consul
    metrics_path: /v1/agent/metrics
    params:
      format: ['prometheus']
    static_configs:
      - targets:
        - '127.0.0.1:8500'

  - job_name: jenkins
    # 1. install Jenkins plug-in Prometheus metrics
    # 2. restart Jenkins
    # 인증을 활성화하려면 젠킨스 시스템설정에서 활성화 가능합니다.
    metrics_path: /prometheus/
    consul_sd_configs:
    - server: '127.0.0.1:8500'
      services: ['jenkins']

  - job_name: nomad
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
    consul_sd_configs:
    - server: '127.0.0.1:8500'
      services: ['nomad','nomad-client']
    relabel_configs:
      - source_labels: ['__meta_consul_tags']
        regex: .*,http,.*
        action: keep

  - job_name: ecr_hello_world
    metrics_path: /actuator/prometheus
    consul_sd_configs:
    - server: '127.0.0.1:8500'
      services: ['ecr-hello-world']

  - job_name: haproxy_exporter
    consul_sd_configs:
    - server: '127.0.0.1:8500'
      services: ['haproxy-exporter']
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
