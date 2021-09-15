job "hello_world" {
  datacenters = ["dc1"]

  group "hello_world" {
    count = 1

    network {
      port "http" { to = 8080 }
    }

    task "hello_world" {
      driver = "docker"

      config {
        image = "gazgeek/springboot-helloworld"
        ports = ["http"]
      }

      resources {
        cpu    = 1000
        memory = 2048
      }

      service {
        name = "hello-world"
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