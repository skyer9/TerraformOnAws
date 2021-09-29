job "kafka-broker" {
  datacenters = ["dc1"]

  group "kafka-broker" {
    count = 1

    network {
      port "http" {}
    }

    task "kafka-broker" {
      driver = "docker"

      config {
        image = "wurstmeister/kafka"
        ports = ["http"]

        auth_soft_fail = true
        network_mode = "host"
      }

      env {
        KAFKA_ADVERTISED_LISTENERS="PLAINTEXT://${NOMAD_IP_http}:${NOMAD_HOST_PORT_http}"
        KAFKA_LISTENERS="PLAINTEXT://0.0.0.0:${NOMAD_HOST_PORT_http}"
        KAFKA_ADVERTISED_HOST_NAME="${NOMAD_IP_http}"
        KAFKA_ADVERTISED_PORT="${NOMAD_HOST_PORT_http}"
        # create from template
        # KAFKA_ZOOKEEPER_CONNECT="zookeeper:2189"
      }

      template {
        data = <<EOF
KAFKA_ZOOKEEPER_CONNECT={{range $index, $service := service "kafka-zookeeper-client" "any"}}{{if ne $index 0}},{{end}}{{ .Address }}:{{ .Port }}{{end}}
EOF
        destination = "secrets/file.env"
        env         = true
        change_mode = "restart"         # 서비스가 바뀌면 재시작
      }

      resources {
        cpu    = 1000
        memory = 512
      }

      service {
        name = "kafka-broker"
        port = "http"

        check {
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
