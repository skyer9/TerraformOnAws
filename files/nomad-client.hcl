datacenter = "dc1"

data_dir = "/opt/nomad"

client {
  enabled = true

  host_volume "grafana" {
    # add directory manually
    # sudo mkdir -p /opt/nomad-volumes/grafana
    # sudo chown 472:472 /opt/nomad-volumes/grafana
    path = "/opt/nomad-volumes/grafana"
  }
  host_volume "jenkins_home" {
    # add directory manually
    # sudo mkdir -p /opt/nomad-volumes/jenkins_home
    # sudo chown 1000:1000 /opt/nomad-volumes/jenkins_home
    path = "/opt/nomad-volumes/jenkins_home"
  }
  host_volume "elasticsearch_data" {
    # add directory manually
    # sudo mkdir -p /opt/nomad-volumes/elasticsearch_data
    # sudo chown 1000:1000 /opt/nomad-volumes/elasticsearch_data
    path = "/opt/nomad-volumes/elasticsearch_data"
  }
  host_volume "elasticsearch_analysis" {
    # add directory manually
    # sudo mkdir -p /opt/nomad-volumes/elasticsearch_analysis
    # sudo chown 1000:1000 /opt/nomad-volumes/elasticsearch_analysis
    path = "/opt/nomad-volumes/elasticsearch_analysis"
  }
}

plugin "docker" {
  config {
    volumes {
      enabled = true
    }

    # 실행 실패시 이미지 삭제
    # 디버깅시 false 로 할것
    gc {
      container   = true
    }

    auth {
      # Nomad will prepend "docker-credential-" to the helper value and call
      # that script name.
      helper = "ecr-login"
    }
  }
}

log_file = "/var/log/nomad/"
log_level = "INFO"

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics       = true
  prometheus_metrics         = true
}
