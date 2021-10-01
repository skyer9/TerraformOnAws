job "logstash-batch" {
  datacenters = ["dc1"]
  type        = "batch"

  group "logstash-batch" {
    count = 1

    task "logstash-batch" {
      driver = "docker"

      artifact {
        source      = "https://downloads.mariadb.com/Connectors/java/connector-java-2.7.4/mariadb-java-client-2.7.4.jar"
      }

      template {
        data = <<EOF
input {
  jdbc {
    jdbc_validate_connection => true
    jdbc_driver_library => "/local/mariadb-java-client-2.7.4.jar"
    jdbc_driver_class => "Java::org.mariadb.jdbc.Driver"
    jdbc_connection_string => "jdbc:mariadb://nb.skyer9.pe.kr:3306/mg"
    jdbc_user => "mg"
    jdbc_password => "********"
    # jdbc_paging_enabled => true
    statement => "SELECT id, restaurant_name, start_date, tel, address, road_address, longitude, latitude, DATE_FORMAT(modify_time, '%Y-%m-%d %H:%m:%s') modify_time, DATE_FORMAT(insert_time, '%Y-%m-%d %H:%m:%s') insert_time FROM tbl_restaurant_info;"
  }
}

output {
  elasticsearch {
    document_id => "%%{id}"
    index => "restaurant_info"
    hosts => [{{range $index, $service := service "main-server-request" "any"}}{{if ne $index 0}},{{end}}"http://{{ .Address }}:{{ .Port }}"{{end}}]
  }
  # stdout{
  #   codec => rubydebug
  # }
}
EOF
        destination = "local/logstash-batch.conf"
      }

      template {
        destination = "local/entrypoint.sh"
        perms = "755"
        change_mode = "noop"
        data = <<EOF
#!/usr/bin/env bash
set -e

bin/logstash -f /local/logstash-batch.conf
EOF
      }

      config {
        image   = "docker.elastic.co/logstash/logstash:7.15.0"
        entrypoint = ["/local/entrypoint.sh"]

        auth_soft_fail = true
      }

      resources {
        cpu    = 1024
        memory = 2048
      }

      service {
        name = "logstash-batch"
      }
    }
  }
}
