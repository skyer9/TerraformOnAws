job "kafka-zk-XXX1-telemetry" {
  datacenters = ["dc1"]
  type = "service"

  group "kafka-zk-XXX1" {

    count = 3

#    meta {
#      cert_ttl            = "168h"
#      cluster_dc          = "XXX1"
#      mtls_path           = "/path/to/kafka/mtls"
#      int_ca_path         = "/path/to/intca/ca"
#      root_ca_path        = "/path/to/rootca/ca"
#    }

    # Run tasks in serial or parallel (1 for serial)
    update {
      max_parallel = 1
      min_healthy_time = "1m"
    }

    restart {
      attempts = 3
      interval = "10m"
      delay    = "30s"
      mode     = "fail"
    }

    migrate {
      max_parallel     = 1
      health_check     = "checks"
      min_healthy_time = "10s"
      healthy_deadline = "5m"
    }

    reschedule {
      delay          = "30s"
      delay_function = "constant"
      unlimited      = true
    }

    ephemeral_disk {
      migrate = false
      size    = "500"
      sticky  = false
    }

    task "kafka-zk-XXX1" {
      driver = "docker"

      artifact {
        source      = "https://releases.hashicorp.com/consul-template/0.27.1/consul-template_0.27.1_linux_amd64.zip"
      }

      config {
        image = "zookeeper"
        entrypoint = ["/local_conf/entrypoint.sh"]

        auth_soft_fail = true

        labels {
          group = "zk-docker"
        }
        network_mode = "host"
        port_map {
          client = 2181
          peer1 = 2888
          peer2 = 3888
          jmx = 9999
        }
        volumes = [
          "local/conf:/local_conf",
          "local/data:/data",
          "local/logs:/logs"
        ]
      }

      env {
        ZOO_CONF_DIR="/conf"
        ZOO_DATA_DIR="/data"
        ZOO_LOG4J_PROP="INFO,CONSOLE"
        ZK_WAIT_FOR_CONSUL_SVC="30"
        ZK_CLIENT_SVC_NAME="kafka-zk-XXX1-client"
        ZK_PEER1_SVC_NAME="kafka-zk-XXX1-peer1"
        ZK_PEER2_SVC_NAME="kafka-zk-XXX1-peer2"
      }

      kill_timeout = "15s"

      resources {
        cpu = 1000
        memory = 1024
        network {
          mbits = 100
          port "client" {}
          port "peer1" {}
          port "peer2" {}
          port "jmx" {}
          port "jolokia" {}
        }
      }
      service {
        port = "client"
        name = "kafka-zk-XXX1-client"
        tags = [
          "kafka-zk-XXX1-telmetry-client",
          "peer1_port=${NOMAD_HOST_PORT_peer1}",
          "peer2_port=${NOMAD_HOST_PORT_peer2}",
          "alloc_index=${NOMAD_ALLOC_INDEX}"
        ]
      }

      service {
        port = "peer1"
        name = "kafka-zk-XXX1-peer1"
        tags = [
          "kafka-zk-XXX1-telemetry-peer1"
        ]
      }
      service {
        port = "peer2"
        name = "kafka-zk-XXX1-peer2"
        tags = [
          "kafka-zk-XXX1-telmetry-peer2"
        ]
      }

      # consul template used to create the zoo.cfg.dyamic file within the entrypoint script.
      template {
        destination = "local/conf/zoo.cfg.dynamic.txt"
        change_mode = "noop"
        left_delimiter = "{{{{{{"
        right_delimiter = "}}}}}}"
        data = <<EOF
{{ range $_, $instance := service (printf "%s|passing" (env "ZK_CLIENT_SVC_NAME")) }}
  {{ range $_, $alloc_index_tag := $instance.Tags }}{{ if $alloc_index_tag | regexMatch "alloc_index=.*" }}
    {{ range $_, $peer1_port_tag := $instance.Tags }}{{ if $peer1_port_tag | regexMatch "peer1_port=.*" }}
      {{ range $_, $peer2_port_tag := $instance.Tags }}{{ if $peer2_port_tag | regexMatch "peer2_port=.*" }}
server.{{ $alloc_index_tag | replaceAll "alloc_index=" "" | parseInt | add 1 }}={{ $instance.Address }}:{{ $peer1_port_tag | replaceAll "peer1_port=" "" }}:{{ $peer2_port_tag | replaceAll "peer2_port=" "" }};{{ $instance.Port }}
      {{ end }}{{ end }}
    {{ end }}{{ end }}
  {{ end }}{{ end }}
{{ end }}
EOF
      }
      # Generate a myid file, which is copied to /data/myid by the entrypoint script.
      template {
        destination = "local/conf/myid"
        change_mode = "noop"
        data = <<EOF
{{ env "NOMAD_ALLOC_INDEX" | parseInt | add 1 }}
EOF
      }
      # as zookeeper dynamically updates zoo.cfg we template to zoo.cfg.tmpl and in the docker-entrypoint.sh of the image copy to zoo.cfg.
      # this prevents the allocation from throwing an error when zookeeper updates zoo.cfg
      template {
        destination = "local/conf/zoo.cfg.tmpl"
        change_mode = "noop"
        data = <<EOF
admin.enableServer=false
tickTime=2000
initLimit=5
syncLimit=2
standaloneEnabled=false
reconfigEnabled=true
skipACL=yes
4lw.commands.whitelist=*
dataDir=/data
dynamicConfigFile=/conf/zoo.cfg.dynamic
EOF
      }

      template {
        destination = "local/conf/entrypoint.sh"
        perms = "755"
        change_mode = "noop"
        data = <<EOF
#!/usr/bin/env bash
set -e

cp /local_conf/* /conf/

# sleep to allow nomad services to be registered in consul and for zookeeper-watcher to run after service changes
echo "start sleep..."
if [[ -z "${ZK_WAIT_FOR_CONSUL_SVC}" ]]; then
    sleep 30 # reasonable default
else
    sleep $ZK_WAIT_FOR_CONSUL_SVC
fi
echo "stop sleep."

# if zoo.cfg.tmpl exists copy to zoo.cfg
if [[ -f "$ZOO_CONF_DIR/zoo.cfg.tmpl" ]]; then
    cp $ZOO_CONF_DIR/zoo.cfg.tmpl $ZOO_CONF_DIR/zoo.cfg
fi

chmod 755 /local/consul-template

# create the zookeeper dynamic cfg from consul template
echo "run consul-template"
if [[ -z "${CONSUL_HTTP_ADDR}" ]]; then
    /local/consul-template -once -template $ZOO_CONF_DIR/zoo.cfg.dynamic.txt:$ZOO_CONF_DIR/zoo.cfg.dynamic
else
    /local/consul-template -once -consul-addr=${CONSUL_HTTP_ADDR} -template $ZOO_CONF_DIR/zoo.cfg.dynamic.txt:$ZOO_CONF_DIR/zoo.cfg.dynamic
fi
echo "finished consul-template"

# myid is generated by Nomad job (myid = allocation index + 1)
cp $ZOO_CONF_DIR/myid $ZOO_DATA_DIR/myid

chown -R zookeeper:zookeeper /data
chown -R zookeeper:zookeeper /logs

su zookeeper -s /bin/bash -c "zkServer.sh start-foreground"
EOF
      }
    }
  }
}
