# source : https://gist.github.com/mykidong/aea105d29e47fafb1ccaeaf2edc5c183
job "kibana" {
  datacenters = ["dc1"]
  type        = "service"

  group "kibana" {
    count = 1

    network {
      port "http" {
        static = 5601
      }
    }

    task "kibana" {
      driver = "docker"

      template {
        data = <<EOF
elasticsearch:
  hosts:
    - http://{{range $index, $element := service "main-server-request"}}{{if eq $index 0}}{{ .Address }}:{{ .Port }}{{end}}{{end}}
EOF
        destination = "local/kibana.yml"
      }

      config {
        image   = "docker.elastic.co/kibana/kibana:7.15.0"
        command = "kibana"

        auth_soft_fail = true

        args = [
          "--server.host=0.0.0.0",
          "--server.port=${NOMAD_PORT_http}"
        ]

        volumes = [
          "local/kibana.yml:/usr/share/kibana/config/kibana.yml",
        ]

        ports = [
          "http"
        ]
      }

      resources {
        cpu    = 1024
        memory = 1024
      }

      service {
        name = "kibana"
        port = "http"
        check {
          name = "kibana-tcp"
          type = "tcp"
          interval = "10s"
          timeout = "2s"
        }
        check {
          name     = "kibana-http"
          port     = "http"
          type     = "tcp"
          interval = "5s"
          timeout  = "4s"
        }
      }
    }
  }
}
