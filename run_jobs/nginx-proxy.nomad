job "nginx-proxy" {
  datacenters = ["dc1"]

  group "nginx-proxy" {
    count = 1

    network {
      port "mg" { static = 28080 }
      port "jenkins" { static = 8000 }
      port "prometheus" { static = 9090 }
      port "grafana" { static = 3000 }
      port "elasticsearch" { static = 9200 }
    }

    task "nginx-proxy" {
      driver = "docker"

      config {
        image = "nginx"
        ports = ["mg", "jenkins"]

        auth_soft_fail = true

        # host 로 설정했으므로 127.0.0.1 는 호스트를 가르킨다.
        # 또, 도커 내에서는 포트 포워딩이 4개까지만 추가할 수 있어, 2개 이상의 서비스를 프록시 할 수 없다.
        network_mode = "host"

        volumes = [
          "local/conf:/etc/nginx/conf.d",
          "/ssl/:/ssl/",
        ]
      }

      template {
        data = <<EOF
upstream mg {
{{ range service "mg" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

upstream jenkins {
{{ range service "jenkins" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

upstream prometheus {
{{ range service "prometheus" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

upstream grafana {
{{ range service "grafana" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

upstream main-server-request {
{{ range service "main-server-request" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
   listen 28080 ssl;
   server_name nb.skyer9.pe.kr;
   ssl_certificate_key /ssl/privkey.pem;
   ssl_certificate /ssl/fullchain.pem;

   location / {
      proxy_pass http://mg;

      proxy_read_timeout 310s;
      proxy_buffering off;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Port 28080;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Origin "${scheme}://${proxy_host}";
   }
}

server {
   listen 8000 ssl;
   server_name nb.skyer9.pe.kr;
   ssl_certificate_key /ssl/privkey.pem;
   ssl_certificate /ssl/fullchain.pem;

   location / {
      proxy_pass http://jenkins;

      proxy_read_timeout 310s;
      proxy_buffering off;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Port 8000;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Origin "${scheme}://${proxy_host}";
   }
}

server {
   listen 9090;

   location / {
      proxy_pass http://prometheus;

      proxy_read_timeout 310s;
      proxy_buffering off;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Port 9090;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Origin "${scheme}://${proxy_host}";
   }
}

server {
   listen 3000;

   location / {
      proxy_pass http://grafana;

      proxy_read_timeout 310s;
      proxy_buffering off;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Port 3000;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Origin "${scheme}://${proxy_host}";
   }
}

server {
   listen 9200;

   location / {
      proxy_pass http://main-server-request;

      proxy_read_timeout 310s;
      proxy_buffering off;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Port 9200;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Origin "${scheme}://${proxy_host}";
   }
}
EOF

        destination   = "local/conf/load-balancer.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      resources {
        cpu    = 1000
        memory = 64
      }

      service {
        name = "nginx-proxy"
        port = "mg"
      }
    }
  }
}
