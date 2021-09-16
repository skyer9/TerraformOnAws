job "jenkins" {
  datacenters = ["dc1"]

  group "jenkins" {
    count = 1

    network {
      port "jenkins_ui" { to = 8080 }
    }

    task "jenkins" {
      driver = "docker"

      config {
        image = "jenkins/jenkins:lts"
        ports = ["jenkins_ui"]

        volumes = [
          "/docker/jenkins:/var/jenkins_home",
          # Docker Out of Docker
          "/var/run/docker.sock:/var/run/docker.sock"
        ]
      }

      resources {
        cpu    = 1000
        memory = 1024
      }

      service {
        name = "jenkins"
        port = "jenkins_ui"

        check {
          type     = "http"
          path     = "/login"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
