job "fabio" {
  datacenters = ["dc1"]
  type = "system"

  group "fabio" {
    network {
      mode = "host"

      port "lb" {
        static = 9999
        to = 9999
      }

      port "ui" {
        static = 9998
        to = 9998
      }
    }

    task "fabio" {
      driver = "docker"

      config {
        image = "fabiolb/fabio"
        network_mode = "host"

        auth_soft_fail = true
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}