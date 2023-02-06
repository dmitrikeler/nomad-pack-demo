job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  type = "service"
  datacenters = [ [[ range $idx, $dc := .support-services.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]

  group "support-services" {
    count = 1
    
    network {
      mode = "bridge"

      port "vault" {
        to = 8200
      }
    }

    service {
      name = "vault"
      provider = "consul"
      port = "vault"
      tags = [
        "support-services",
        "traefik.enable=true",
        "traefik.connect=true",
        "traefik.consulcatalog.connect=true",
        # Vault's UI (and API) is not able to work with domain subpathing
        # "traefik.http.routers.vault.rule=Host(`devops.internal`) && Path(`/vault*`)"
        "traefik.http.routers.vault.rule=Host(`[[ .support-services.vault_ui_url ]]`)"
      ]

      address_mode = "alloc"

      connect {
        sidecar_service {} 
      }

      check {
        type          = "http"
        port          = "vault"
        path          = "/v1/sys/health"
        interval      = "10s"
        timeout       = "2s"
        address_mode  = "alloc"
      }
    }

    task "vault" {
      driver = "docker"

      resources {
        cpu    = 200
        memory = 256
      }
        
      config {
        image = [[ .support-services.docker_image | quote ]]
        args  = ["server", "-dev", "-log-level=[[ .support-services.vault_log_level ]]"]
        ports = ["vault"]
      }
    }

    task "gonsul" {
      driver = "docker"

      lifecycle {
        hook = "poststart"
        sidecar = true
      }

      resources {
        cpu    = [[ .support-services.resources.cpu ]]
        memory = [[ .support-services.resources.memory ]]
      }

      env {
        GONSUL_REPO_URL = [[ .support-services.gonsul_repo_url | quote ]]
        GONSUL_REPO_BASE_PATH = "configuration/"
        GONSUL_CONSUL_BASE_PATH = ""
        GONSUL_REPO_SSH_KEY = "/secrets/id_rsa"
      }

      template {
        data = <<EOF
[[ .support-services.gonsul_private_key ]]
EOF
        destination = "/secrets/id_rsa"
        change_mode = "restart"
      }

      template {
        data = <<EOF
{{ range service "consul" }}
GONSUL_CONSUL_URL=http://{{ .Address }}:8500
{{ end }}
EOF
        destination = "/secrets/config.env"
        change_mode = "restart"
        env         = true
      }
        
      config {
        image = "docker-new.finnplay.net/gonsul:1"

        auth {
          username = "docker"
          password = "iu2BXyS9qmRB8dJ2wSExFaXq"
        }
      }
    }
  }
}