job "www-t18s" {
  datacenters = [
    "bi-sbg"]

  group "backend" {
    count = 2

    shutdown_delay = "20s"

    reschedule {
      attempts = 5
      interval = "1h"
      delay = "30s"
      delay_function = "constant"
      unlimited = false
    }

    restart {
      attempts = 3
      interval = "5m"
      delay = "30s"
      mode = "fail"
    }

    update {
      max_parallel     = 1
      health_check     = "checks"
      min_healthy_time = "10s"
      healthy_deadline = "2m"
      progress_deadline = "10m"
      stagger = "15s"
    }

    migrate {
      max_parallel     = 1
      health_check     = "checks"
      min_healthy_time = "10s"
      healthy_deadline = "2m"
    }

    constraint {
      attribute = "${meta.client_type}"
      value = "node"
    }

    constraint {
      distinct_hosts = true
    }

    task "docker-image" {
      driver = "docker"

      config {
        image = "ghcr.io/tristan-weil/www-t18s/nginx:v0.0.6"

        volumes = [
          "local:/etc/nginx/conf.d",
        ]
      }

      resources {
        network {
          mode = "host"
          port "http" {}
        }
      }

      service {
        name = "www-t18s"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.www-t18s.rule=Host(`t18s.fr`) || HostRegexp(`{subdomain:[a-z]+}.t18s.fr`)",
          "traefik.http.routers.www-t18s.entrypoints=web,websecure",

          "traefik.http.routers.www-t18s.tls=true",
          "traefik.http.routers.www-t18s.tls.certResolver=letsencrypt",
          "traefik.http.routers.www-t18s.tls.domains[0].main=t18s.fr",
          "traefik.http.routers.www-t18s.tls.domains[0].sans=*.t18s.fr",

          "traefik.http.middlewares.www-t18s-redirect.redirectRegex.regex=^https?://(?:.+\\.)?t18s.fr",
          "traefik.http.middlewares.www-t18s-redirect.redirectRegex.replacement=https://t18s.fr",
          "traefik.http.middlewares.www-t18s-redirect.redirectRegex.permanent=true",

          "traefik.http.routers.www-t18s.middlewares=www-t18s-redirect@consulcatalog,secure-headers@file"
        ]

        check {
          type = "http"
          port = "http"
          path = "/"
          interval = "15s"
          timeout = "2s"
        }
      }

      template {
        data = <<EOF
server {
    listen       {{ env "NOMAD_PORT_http" }};
    server_name  _;

    include /etc/nginx/www/t18s.conf;
}
EOF

        destination = "local/default.conf"
        change_mode = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}
