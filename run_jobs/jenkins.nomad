job "jenkins" {
  datacenters = ["dc1"]

  group "jenkins" {
    count = 1

    network {
      port "jenkins_ui" { to = 8080 }

      port "nomad" { to = 4646 }
    }

    volume "jenkins_home" {
      type   = "host"
      source = "jenkins_home"
    }

    task "jenkins" {
      driver = "docker"

      config {
        image = "skyer9/jenkins-docker:0.0.3"
        ports = ["jenkins_ui", "nomad"]

        auth_soft_fail = true

        volumes = [
          # Docker Out of Docker
          "/var/run/docker.sock:/var/run/docker.sock"
        ]
      }

      volume_mount {
        volume      = "jenkins_home"
        destination = "/var/jenkins_home"
      }

      resources {
        cpu    = 1000
        memory = 1024     # 1G 이상으로 할것!!
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
