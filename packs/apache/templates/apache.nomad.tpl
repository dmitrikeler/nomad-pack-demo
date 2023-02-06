job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  type = "service"
  datacenters = [ [[ range $idx, $dc := .apache.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]

  group "apache" {
    count = [[ .apache.job_count ]]
    
    network {
      mode = "bridge"

      port "http" {
        to = [[ .apache.http_port ]]
      }
    }

    [[ if .apache.register_service ]]
    service {
      name = "[[ .apache.service_name ]]"
      provider = "consul"
      port = "http"
      tags = [
        "infrastructure",
        "webserver",
        "traefik.enable=true",
        "traefik.connect=true",
        "traefik.consulcatalog.connect=true",
        "traefik.http.routers.apache.rule=Host(`[[ .apache.http_url ]]`)"
        #"traefik.http.routers.apache.rule=Host(`devops-demo.finnplay.net`) && Path(`/apache`)"
      ]

      address_mode = "alloc"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "vault"
              local_bind_port  = 8200
            }
          }
        }
      }

      check {
        type          = "http"
        port          = "http"
        path          = "/"
        interval      = "10s"
        timeout       = "2s"
        address_mode  = "alloc"
      }
    }
    [[ end ]]

    task "apache" {
      driver = "docker"

      resources {
        cpu    = [[ .apache.resources.cpu ]]
        memory = [[ .apache.resources.memory ]]
      }

      env {
        VAULT_TOKEN = [[.apache.vault_token | quote]]
      }

      template {
        data = <<EOF
{{ range service "consul" }}
CONSUL_ADDRESS=http://{{ .Address }}:8500
{{ end }}
EOF
        destination = "/secrets/config.env"
        change_mode = "restart"
        env         = true
      }
        
      config {
        image = "[[ .apache.docker_image ]]"
        ports = ["http"]

        args = [
          "-consul-addr=${CONSUL_ADDRESS}",
          "-vault-addr=http://127.0.0.1:8200"
        ]

        auth {
          username = [[.apache.docker_username | quote]]
          password = [[.apache.docker_password | quote]]
        }
      }
    }
  }
}
