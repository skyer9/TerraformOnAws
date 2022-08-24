job "haproxy" {
  datacenters = ["dc1"]
  type = "system"         # 모든 노드에 자동설치

  group "haproxy" {
    count = 1

    network {
      port "haproxy_ui" {
        static = 4936
      }

      port "prometheus_ui" {
        static = 9090
      }

      port "hello_world" {
        static = 2390
      }

      port "haproxy_exporter" {}
    }

    task "haproxy" {
      driver = "docker"

      config {
        image = "haproxy:2.4.4"
        ports = ["haproxy_ui"]

        auth_soft_fail = true

        # host 로 설정했으므로 127.0.0.1 는 호스트를 가르킨다.
        network_mode = "host"

        volumes = [
          "local/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg",
          "/ssl/:/ssl/",
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
   option forwardfor

frontend stats
   bind *:{{ env "NOMAD_PORT_haproxy_ui" }}
   stats uri /
   stats show-legends
   no log

frontend prometheus_ui_front
   bind *:{{ env "NOMAD_PORT_prometheus_ui" }}
   default_backend prometheus_ui_back

backend prometheus_ui_back
   balance roundrobin
   server-template prometheus_ui 5 _prometheus._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

frontend hello_world_front
   bind *:{{ env "NOMAD_PORT_hello_world" }}
   default_backend hello_world_back

backend hello_world_back
   balance roundrobin
   server-template hello_world 5 _hello-world._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

resolvers consul
   nameserver consul 127.0.0.1:8600
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