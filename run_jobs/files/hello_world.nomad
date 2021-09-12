job "hello_world" {
  datacenters = ["dc1"]

  group "hello_world" {
    count = 1

    network {
      port "http" {}
    }

    task "hello_world" {
      driver = "docker"

      config {
        image = "gazgeek/springboot-helloworld"
        ports = ["http"]

        args = [
          "--server.port=${NOMAD_PORT_http}"
        ]
      }

      resources {
        cpu    = 1000
        memory = 1024
      }

      service {
        name = "hello_world"
        port = "http"

        check {
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
