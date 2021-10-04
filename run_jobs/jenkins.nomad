job "jenkins" {
  datacenters = ["dc1"]

  group "jenkins" {
    count = 1

    network {
      port "jenkins_ui" {}
    }

    volume "jenkins_home" {
      type   = "host"
      source = "jenkins_home"
    }

    task "jenkins" {
      driver = "docker"

      config {
        image = "skyer9/jenkins-docker:0.0.4"
        ports = ["jenkins_ui"]

        auth_soft_fail = true

        # host 로 설정했으므로 127.0.0.1 는 호스트를 가르킨다.
        network_mode = "host"

        volumes = [
          # Docker Out of Docker
          "/var/run/docker.sock:/var/run/docker.sock"
        ]
      }

      env {
        JENKINS_JAVA_OPTIONS="-Dorg.apache.commons.jelly.tags.fmt.timeZone=Asia/Seoul"
        JENKINS_OPTS="--httpPort=${NOMAD_PORT_jenkins_ui}"
      }

      volume_mount {
        volume      = "jenkins_home"
        destination = "/var/jenkins_home"
      }

      resources {
        cpu    = 1000
        memory = 2048     # 2G 이상으로 할것!!
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
