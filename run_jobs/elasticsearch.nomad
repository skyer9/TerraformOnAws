job "elasticsearch" {
  datacenters = ["dc1"]

  group "elasticsearch" {
    count = 1

    network {
      port "http" { to = 9200 }
    }

    task "elasticsearch" {
      driver = "docker"

      template {
        data = <<EOH
cluster.name: "my-elasticsearch"
network.host: 0.0.0.0
discovery.zen.minimum_master_nodes: 1
xpack.license.self_generated.type: basic
        EOH

        destination = "local/elasticsearch.yml"
      }

      config {
        # image = "docker.elastic.co/elasticsearch/elasticsearch:6.8.10"
        image = "skyer9/elasticsearch-consul:6.8.10"
        ports = ["http"]

        auth_soft_fail = true

        port_map {
          http = 9200
        }

        volumes = [
          "local/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml",
        ]
      }

      resources {
        cpu    = 1000
        memory = 2048
      }

      service {
        name = "elasticsearch"
        port = "http"

        tags = ["urlprefix-/elasticsearch"]
        # port 를 이용한 proxy 는 fabio 재실행이 필요하다.
        # https://fabiolb.net/feature/tcp-proxy/
        # tags = ["urlprefix-:9200 proto=tcp"]

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}