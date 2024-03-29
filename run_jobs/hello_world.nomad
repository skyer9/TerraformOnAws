job "hello_world" {
  datacenters = ["dc1"]

  group "hello_world" {
    count = 1

    network {
      port "http" { to = 80 }
    }

    task "hello_world" {
      driver = "docker"

      config {
        image = "nginxdemos/hello"
        ports = ["http"]

        auth_soft_fail = true
      }

      resources {
        cpu    = 500
        memory = 128
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