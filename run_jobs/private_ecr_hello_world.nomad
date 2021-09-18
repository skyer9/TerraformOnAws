job "private_ecr_hello_world" {
  datacenters = ["dc1"]

  group "private_ecr_hello_world" {
    count = 1

    network {
      port "http" { to = 8080 }
    }

    task "private_ecr_hello_world" {
      driver = "docker"

      config {
        image = "https://XXXXXXXXXX.dkr.ecr.ap-northeast-2.amazonaws.com/helloworld:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 1000
        memory = 2048
      }

      service {
        name = "ecr-hello-world"
        port = "http"

        check {
          type     = "http"
          path     = "/actuator/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}