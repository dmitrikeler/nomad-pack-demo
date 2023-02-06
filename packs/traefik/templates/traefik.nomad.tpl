job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := .traefik.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type        = "system"

  group "traefik" {
    count = [[ .traefik.job_count ]]

    network {
      port "http" {
        static = 80
      }

      port "api" {
        static = 8081
      }

      port "consul" {
        static = 8500
      }
    }

    service {
      name = "traefik-ingress"
      provider = "consul"
      port = "http"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }

      connect {
        native = true
      }
    }

    service {
      name = "traefik-ui"
      provider = "consul"
      port = "api"
      tags = [
        "infrastructure",
        "traefik.enable=true",
        # Traefik's UI does not work with domain subpathing
        "traefik.http.routers.traefik.rule=Host(`[[ .traefik.traefik_ui_url ]]`)"
      ]

      address_mode = "host"

      check {
        type     = "http"
        port     = "api"
        path     = "/ping"
        interval = "10s"
        timeout  = "2s"
        address_mode = "host"
      }
    }

    service {
      name = "consul-ui"
      provider = "consul"
      port = "consul"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.consul.rule=Host(`[[ .traefik.consul_ui_url ]]`)"
      ]

      check {
        type     = "http"
        port     = "consul"
        path     = "/v1/status/leader"
        interval = "10s"
        timeout  = "2s"
      }
    }


    task "traefik" {
      driver = "docker"

      config {
        image        = [[ .traefik.docker_image | quote ]]
        network_mode = "host"

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]

        args = [
          "--api.dashboard=true",
          "--api.insecure=true",
        ]
      }

      template {
        data = <<EOF
[entryPoints]
    [entryPoints.http]
    address = ":80"
    [entryPoints.traefik]
    address = ":8081"

[ping]
    entryPoint = "traefik"

[api]
    dashboard = true
    insecure  = true

[log]
    level = "INFO"

# Enable Consul Catalog configuration backend.
[providers.consulCatalog]
    prefix           = "traefik"
    exposedByDefault = false
    connectAware = true
    connectByDefault = false
    serviceName = "traefik-ingress"

    [providers.consulCatalog.endpoint]
      address = "127.0.0.1:8500"
      scheme  = "http"
EOF

        destination = "local/traefik.toml"
      }

      resources {
        cpu    = [[ .traefik.resources.cpu ]]
        memory = [[ .traefik.resources.memory ]]
      }
    }
  }
}
