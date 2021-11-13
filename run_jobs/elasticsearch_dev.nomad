# source : https://gist.github.com/mykidong/aea105d29e47fafb1ccaeaf2edc5c183
job "elasticsearch" {
  datacenters = ["dc1"]
  type        = "service"

  group "single-server" {
    count = 1

    network {
      port "request" {}
      port "communication" {}
    }

    volume "elasticsearch_data" {
      type   = "host"
      source = "elasticsearch_data"
    }

    volume "elasticsearch_analysis" {
      type   = "host"
      source = "elasticsearch_analysis"
    }

    task "elasticsearch" {
      driver = "docker"

      template {
        data        = <<EOF
cluster:
  name: my-cluster
  publish:
    timeout: 300s
  join:
    timeout: 300s
  initial_master_nodes:
    - {{ env "NOMAD_IP_communication" }}:{{ env "NOMAD_HOST_PORT_communication" }}
node:
  name: single-server
  master: true
  data: true
  ingest: true
network:
  host: 0.0.0.0
discovery:
  seed_hosts:
    - {{ env "NOMAD_IP_communication" }}:{{ env "NOMAD_HOST_PORT_communication" }}
bootstrap.memory_lock: true
indices.query.bool.max_clause_count: 10000
EOF
        destination = "local/elasticsearch.yml"
      }

      config {
        image   = "docker.elastic.co/elasticsearch/elasticsearch:7.15.1"
        # image   = "skyer9/elasticsearch-jaso-analyzer:7.15.1.1"
        command = "elasticsearch"

        args = [
          "-Enetwork.publish_host=${NOMAD_IP_request}",
          "-Ehttp.publish_port=${NOMAD_HOST_PORT_request}",
          "-Ehttp.port=${NOMAD_PORT_request}",
          "-Etransport.publish_port=${NOMAD_HOST_PORT_communication}",
          "-Etransport.tcp.port=${NOMAD_PORT_communication}"
        ]

        ports = [
          "request",
          "communication"
        ]

        ulimit {
          memlock = "-1"
          nofile  = "65536"
          nproc   = "65536"
        }

        volumes = [
          "local/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml"
        ]
      }

      volume_mount {
        volume      = "elasticsearch_data"
        destination = "/usr/share/elasticsearch/data"
      }

      volume_mount {
        volume      = "elasticsearch_analysis"
        destination = "/usr/share/elasticsearch/config/analysis"
      }

      resources {
        cpu    = 1000
        memory = 4096
      }

      service {
        name = "main-server-request"
        port = "request"
        check {
          name     = "rest-tcp"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
        check {
          name     = "rest-http"
          type     = "http"
          path     = "/"
          interval = "5s"
          timeout  = "4s"
        }
      }

      service {
        name = "main-server-communication"
        port = "communication"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
