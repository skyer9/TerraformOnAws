# https://itnext.io/trino-on-nomad-79cb398a826
#job "trino" {
#  namespace = "trino"
#  ...
#  group "coordinator" {
#    count = 1
#    ...
#  }
#  group "worker" {
#    count = 3
#    ...
#  }
#  group "cli" {
#    count = 1
#    ...
#  }
#}

job "trino" {
  # nomad namespace apply -description "trino cluster" trino
  namespace   = "trino"
  datacenters = ["dc1"]
  type        = "service"

  group "coordinator" {
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

    task "trino-server" {
      driver       = "docker"
      kill_timeout = "300s"
      kill_signal  = "SIGTERM"

      template {
        data = <<EOF
coordinator=true
node-scheduler.include-coordinator=false
http-server.http.port={{ env "NOMAD_HOST_PORT_http" }}
query.max-memory=5GB
query.max-memory-per-node=1GB
query.max-total-memory-per-node=2GB
query.max-stage-count=200
task.writer-count=4
discovery-server.enabled=true
discovery.uri=http://{{ env "NOMAD_IP_http" }}:{{ env "NOMAD_HOST_PORT_http" }}
EOF
        destination = "local/config.properties"
      }

      template {
        data = <<EOF
node.id={{ env "NOMAD_NAMESPACE" }}-{{ env "NOMAD_JOB_NAME" }}-{{ env "NOMAD_GROUP_NAME" }}-{{ env "NOMAD_ALLOC_ID" }}
node.environment=production
node.data-dir=/usr/lib/trino/data
spiller-spill-path=/tmp
max-spill-per-node=4TB
query-max-spill-per-node=1TB
EOF
        destination = "local/node.properties"
      }

      template {
        data = <<EOF
-server
-Xmx16G
-XX:-UseBiasedLocking
-XX:+UseG1GC
-XX:G1HeapRegionSize=32M
-XX:+ExplicitGCInvokesConcurrent
-XX:+ExitOnOutOfMemoryError
-XX:+HeapDumpOnOutOfMemoryError
-XX:ReservedCodeCacheSize=512M
-XX:PerMethodRecompilationCutoff=10000
-XX:PerBytecodeRecompilationCutoff=10000
-Djdk.attach.allowAttachSelf=true
-Djdk.nio.maxCachedBufferSize=2000000
EOF
        destination = "local/jvm.config"
      }

      template {
        data = <<EOF
connector.name=hive-hadoop2
hive.metastore.uri=thrift://{{range $index, $element := service "hive-metastore"}}{{if eq $index 0}}{{ .Address }}:{{ .Port }}{{end}}{{end}}
hive.allow-drop-table=true
hive.max-partitions-per-scan=1000000
hive.compression-codec=NONE
hive.s3.endpoint=https://nginx-test.cloudchef-labs.com
hive.s3.path-style-access=true
hive.s3.ssl.enabled=true
hive.s3.max-connections=100
hive.s3.aws-access-key=cclminio
hive.s3.aws-secret-key=rhksflja!@#
EOF
        destination = "local/catalog/hive.properties"
      }

      template {
        data = <<EOF
connector.name=mysql
connection-url=jdbc:mysql://nb.skyer9.pe.kr:3306
connection-user=mg
connection-password=abcd1234
EOF
        destination = "local/catalog/mysql.properties"
      }

      config {
        image = "trinodb/trino"
        force_pull = false

        auth_soft_fail = true

        volumes = [
          "./local/config.properties:/usr/lib/trino/etc/config.properties",
          "./local/node.properties:/usr/lib/trino/etc/node.properties",
          "./local/jvm.config:/usr/lib/trino/etc/jvm.config",
          # "./local/catalog/hive.properties:/usr/lib/trino/etc/catalog/hive.properties",
          "./local/catalog/mysql.properties:/usr/lib/trino/etc/catalog/mysql.properties"
        ]

        command = "/usr/lib/trino/bin/launcher"

        args = [
          "run"
        ]

        ports = [
          "http"
        ]

        ulimit {
          nofile = "131072"
          nproc  = "65536"
        }
      }

      resources {
        cpu = 200
        memory = 2048
      }

      service {
        name = "trino-coordinator"
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

  group "worker" {
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

    task "await-coordinator" {
      driver = "docker"

      config {
        image          = "busybox:1.28"
        auth_soft_fail = true
        command        = "sh"
        args           = ["-c", "echo -n 'Waiting for service'; until nslookup trino-coordinator.service.consul 127.0.0.1:8600 2>&1 >/dev/null; do echo '.'; sleep 2; done"]
        network_mode   = "host"
      }

      resources {
        cpu    = 100
        memory = 128
      }

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
    }

    task "trino-server" {
      driver = "docker"
      kill_timeout = "300s"
      kill_signal = "SIGTERM"

      template {
        data = <<EOF
coordinator=false
http-server.http.port={{ env "NOMAD_HOST_PORT_http" }}
query.max-memory=5GB
query.max-memory-per-node=1GB
query.max-total-memory-per-node=2GB
query.max-stage-count=200
task.writer-count=4
discovery.uri=http://{{range $index, $element := service "trino-coordinator"}}{{if eq $index 0}}{{ .Address }}:{{ .Port }}{{end}}{{end}}
EOF
        destination = "local/config.properties"
      }

      template {
        data = <<EOF
node.id={{ env "NOMAD_NAMESPACE" }}-{{ env "NOMAD_JOB_NAME" }}-{{ env "NOMAD_GROUP_NAME" }}-{{ env "NOMAD_ALLOC_ID" }}
node.environment=production
node.data-dir=/usr/lib/trino/data
spiller-spill-path=/tmp
max-spill-per-node=4TB
query-max-spill-per-node=1TB
EOF
        destination = "local/node.properties"
      }

      template {
        data = <<EOF
-server
-Xmx16G
-XX:-UseBiasedLocking
-XX:+UseG1GC
-XX:G1HeapRegionSize=32M
-XX:+ExplicitGCInvokesConcurrent
-XX:+ExitOnOutOfMemoryError
-XX:+HeapDumpOnOutOfMemoryError
-XX:ReservedCodeCacheSize=512M
-XX:PerMethodRecompilationCutoff=10000
-XX:PerBytecodeRecompilationCutoff=10000
-Djdk.attach.allowAttachSelf=true
-Djdk.nio.maxCachedBufferSize=2000000
EOF
        destination = "local/jvm.config"
      }

      template {
        data = <<EOF
connector.name=hive-hadoop2
hive.metastore.uri=thrift://{{range $index, $element := service "hive-metastore"}}{{if eq $index 0}}{{ .Address }}:{{ .Port }}{{end}}{{end}}
hive.allow-drop-table=true
hive.max-partitions-per-scan=1000000
hive.compression-codec=NONE
hive.s3.endpoint=https://nginx-test.cloudchef-labs.com
hive.s3.path-style-access=true
hive.s3.ssl.enabled=true
hive.s3.max-connections=100
hive.s3.aws-access-key=cclminio
hive.s3.aws-secret-key=rhksflja!@#
EOF
        destination = "local/catalog/hive.properties"
      }

      template {
        data = <<EOF
connector.name=mysql
connection-url=jdbc:mysql://nb.skyer9.pe.kr:3306
connection-user=mg
connection-password=abcd1234
EOF
        destination = "local/catalog/mysql.properties"
      }

      config {
        image = "trinodb/trino"
        force_pull = false

        auth_soft_fail = true

        volumes = [
          "./local/config.properties:/usr/lib/trino/etc/config.properties",
          "./local/node.properties:/usr/lib/trino/etc/node.properties",
          "./local/jvm.config:/usr/lib/trino/etc/jvm.config",
          # "./local/catalog/hive.properties:/usr/lib/trino/etc/catalog/hive.properties",
          "./local/catalog/mysql.properties:/usr/lib/trino/etc/catalog/mysql.properties"
        ]

        command = "/usr/lib/trino/bin/launcher"

        args = [
          "run"
        ]

        ports = [
          "http"
        ]

        ulimit {
          nofile = "131072"
          nproc  = "65536"
        }
      }

      resources {
        cpu    = 200
        memory = 2048
      }

      service {
        name = "trino-worker"
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

  # client
  # trino --server=http://192.168.0.9:31625
}
