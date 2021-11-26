job "zeppelin" {
  datacenters = ["dc1"]
  type        = "service"

  group "zeppelin" {
    count = 1

    restart {
      attempts = 3
      delay    = "30s"
      interval = "5m"
      mode     = "fail"
    }

    network {
      port "http" {
      }
    }

    volume "zeppelin_logs" {
      type   = "host"
      source = "zeppelin_logs"
    }

    volume "zeppelin_notebook" {
      type   = "host"
      source = "zeppelin_notebook"
    }

    task "zeppelin" {
      driver       = "docker"
      kill_timeout = "300s"
      kill_signal  = "SIGTERM"

      config {
        image = "apache/zeppelin:0.10.0"
        force_pull = false

        auth_soft_fail = true

        command = "/opt/zeppelin/bin/zeppelin.sh"

        args = [
          "run"
        ]

        ports = [
          "http"
        ]
      }

      volume "zeppelin_logs" {
        type   = "host"
        destination = "/opt/zeppelin/logs"
      }

      volume "zeppelin_notebook" {
        type   = "host"
        destination = "/opt/zeppelin/notebook"
      }

      resources {
        cpu = 200
        memory = 2048
      }

      service {
        name = "zeppelin"
        port = "http"

        check {
          name     = "rest-tcp"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}