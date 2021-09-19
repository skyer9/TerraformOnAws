job "haproxy" {
  datacenters = ["dc1"]

  group "haproxy" {
    count = 1

    network {
      port "webapp" {
        static = 8080
      }

      port "hello_world" {
        static = 9999
      }

      port "prometheus_ui" {
        static = 9090
      }

      port "grafana_ui" {
        static = 3000
      }

      port "haproxy_ui" {
        static = 4936
      }

      port "jenkins_ui" {
        static = 8000
      }

      port "haproxy_exporter" {}
    }

    task "haproxy" {
      driver = "docker"

      config {
        image = "haproxy:2.3.5"
        ports = ["webapp", "hello_world", "prometheus_ui", "grafana_ui", "haproxy_ui", "jenkins_ui"]

        auth_soft_fail = true

        # Use `host` network so we can communicate with the Consul agent
        # running in the host to access the service catalog.
        network_mode = "host"

        volumes = [
          "local/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg",
        ]
      }

      template {
        data = <<EOF
global
   maxconn 8192

defaults
   mode http
   timeout client 10s
   timeout connect 5s
   timeout server 10s
   timeout http-request 10s

frontend stats
   bind *:{{ env "NOMAD_PORT_haproxy_ui" }}
   stats uri /
   stats show-legends
   no log

frontend http_front
   bind *:{{ env "NOMAD_PORT_webapp" }}
   default_backend http_back

frontend hello_world_front
   bind *:{{ env "NOMAD_PORT_hello_world" }}
   default_backend hello_world_back

frontend prometheus_ui_front
   bind *:{{ env "NOMAD_PORT_prometheus_ui" }}
   default_backend prometheus_ui_back

frontend grafana_ui_front
   bind *:{{ env "NOMAD_PORT_grafana_ui" }}
   default_backend grafana_ui_back

frontend jenkins_ui_front
   bind *:{{ env "NOMAD_PORT_jenkins_ui" }}
   default_backend jenkins_ui_back

backend http_back
   balance roundrobin
   server-template webapp 20 _hello-world._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

backend hello_world_back
   balance roundrobin
   server-template hello_world 20 _ecr-hello-world._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

backend prometheus_ui_back
   balance roundrobin
   server-template prometheus_ui 5 _prometheus._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

backend grafana_ui_back
   balance roundrobin
   server-template grafana 5 _grafana._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

backend jenkins_ui_back
   balance roundrobin
   server-template jenkins_ui 5 _jenkins._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

resolvers consul
   nameserver consul {{ env "attr.unique.network.ip-address" }}:8600
   accepted_payload_size 8192
   hold valid 5s
EOF

        destination   = "local/haproxy.cfg"
        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }

      resources {
        cpu    = 500
        memory = 128
      }

      service {
        name = "haproxy-ui"
        port = "haproxy_ui"

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      service {
        name = "haproxy-webapp"
        port = "webapp"
      }

      service {
        name = "haproxy-jenkins-ui"
        port = "jenkins_ui"
      }
    }

    task "haproxy-exporter" {
      driver = "docker"

      lifecycle {
        hook    = "prestart"
        sidecar = true
      }

      config {
        image = "prom/haproxy-exporter:v0.10.0"
        ports = ["haproxy_exporter"]

        network_mode = "host"
        auth_soft_fail = true

        args = [
          "--web.listen-address",
          ":${NOMAD_PORT_haproxy_exporter}",
          "--haproxy.scrape-uri",
          "http://${NOMAD_ADDR_haproxy_ui}/?stats;csv",
        ]
      }

      resources {
        cpu    = 100
        memory = 32
      }

      service {
        name = "haproxy-exporter"
        port = "haproxy_exporter"

        check {
          type     = "http"
          path     = "/metrics"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}