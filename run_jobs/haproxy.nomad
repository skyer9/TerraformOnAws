job "haproxy" {
  datacenters = ["dc1"]
  type = "system"         # 모든 노드에 자동설치

  group "haproxy" {
    count = 1

    network {
#      port "webapp" {
#        static = 8080
#      }

#      port "hello_world" {
#        static = 19999
#      }

#      port "prometheus_ui" {
#        static = 9090
#      }

      port "grafana_ui" {
        static = 3000
      }

      port "haproxy_ui" {
        static = 4936
      }

      port "trino_cluster" {
        static = 8090
      }

      port "zeppelin" {
        static = 10000
      }

      port "jenkins" {
        static = 8000
      }

      port "elasticsearch" {
        static = 9200
      }

      port "mg" {
        static = 28080
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

#frontend http_front
#   bind *:{{ env "NOMAD_PORT_webapp" }}
#   default_backend http_back
#
#frontend hello_world_front
#   bind *:{{ env "NOMAD_PORT_hello_world" }}
#   default_backend hello_world_back
#
#frontend prometheus_ui_front
#   bind *:{{ env "NOMAD_PORT_prometheus_ui" }}
#   default_backend prometheus_ui_back

frontend grafana_ui_front
   # bind *:{{ env "NOMAD_PORT_grafana_ui" }}
   bind *:{{ env "NOMAD_PORT_grafana_ui" }} ssl crt /ssl/ssl.pem

   default_backend grafana_ui_back

   acl grafana-ssl-acl path_beg /.well-known/acme-challenge/
   use_backend grafana-ssl-backend if grafana-ssl-acl

frontend zeppelin_front
   bind *:{{ env "NOMAD_PORT_zeppelin" }} ssl crt /ssl/ssl.pem

   default_backend zeppelin_back

   acl zeppelin-ssl-acl path_beg /.well-known/acme-challenge/
   use_backend zeppelin-ssl-backend if zeppelin-ssl-acl

frontend trino_cluster_front
   bind *:{{ env "NOMAD_PORT_trino_cluster" }}
   default_backend trino_cluster_back

frontend jenkins_front
   bind *:{{ env "NOMAD_PORT_jenkins" }} ssl crt /ssl/ssl.pem

   default_backend jenkins_back

   acl jenkins-ssl-acl path_beg /.well-known/acme-challenge/
   use_backend jenkins-ssl-backend if jenkins-ssl-acl

frontend elasticsearch_front
   bind *:{{ env "NOMAD_PORT_elasticsearch" }} ssl crt /ssl/ssl.pem

   default_backend elasticsearch_back

   acl elasticsearch-ssl-acl path_beg /.well-known/acme-challenge/
   use_backend elasticsearch-ssl-backend if elasticsearch-ssl-acl

frontend mg_front
   bind *:{{ env "NOMAD_PORT_mg" }} ssl crt /ssl/ssl.pem

   default_backend mg_back

   acl mg-ssl-acl path_beg /.well-known/acme-challenge/
   use_backend mg-ssl-backend if mg-ssl-acl

#backend http_back
#   balance roundrobin
#   server-template webapp 20 _hello-world._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check
#
#backend hello_world_back
#   balance roundrobin
#   server-template hello_world 20 _ecr-hello-world._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check
#
#backend prometheus_ui_back
#   balance roundrobin
#   server-template prometheus_ui 5 _prometheus._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

backend grafana_ui_back
   balance roundrobin
   server-template grafana 5 _grafana._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

backend grafana-ssl-backend
   server grafana *:{{ env "NOMAD_PORT_grafana_ui" }}

backend zeppelin_back
   balance roundrobin
   server test_site1 nb.skyer9.pe.kr:9999 check inter 5s rise 3 fall 2

backend zeppelin-ssl-backend
   server zeppelin *:{{ env "NOMAD_PORT_zeppelin" }}

backend trino_cluster_back
   balance roundrobin
   server-template trino_cluster 5 _trino-coordinator._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

backend jenkins_back
   balance roundrobin
   server-template jenkins 5 _jenkins._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check
   http-request set-header X-Forwarded-Port %[dst_port]
   http-request add-header X-Forwarded-Proto https if { ssl_fc }

backend jenkins-ssl-backend
   server jenkins *:{{ env "NOMAD_PORT_jenkins" }}

backend elasticsearch_back
   balance roundrobin
   server-template elasticsearch 5 _main-server-request._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

backend elasticsearch-ssl-backend
   server elasticsearch *:{{ env "NOMAD_PORT_elasticsearch" }}

backend mg_back
   balance roundrobin
   server-template mg 5 _mg._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

backend mg-ssl-backend
   server mg *:{{ env "NOMAD_PORT_mg" }}

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
