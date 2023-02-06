variable "job_name" {
    description = "The name to use as the job name which overrides using the pack name"
    type        = string
    default     = "traefik"
}

variable "job_count" {
    description = "How many instances to start"
    type        = number
    default     = 1
}

variable "datacenters" {
    description = "A list of datacenters in the region which are eligible for task placement"
    type        = list(string)
    default     = ["dc1"]
}

variable "region" {
    description = "The region where the job should be placed"
    type        = string
    default     = "global"
}

variable "docker_image" {
    description = "The docker image version"
    type        = string
    default     = "traefik:latest"
}

variable "traefik_ui_url" {
    description = "URL for exposing Traefik web UI"
    type        = string
    default     = "traefik.local"
}

variable "consul_ui_url" {
    description = "URL for exposing Consul web UI"
    type        = string
    default     = "consul.local"
}

variable "nomad_ui_url" {
    description = "URL for exposing Nomad web UI"
    type        = string
    default     = "nomad.local"
}

variable "resources" {
    description = "The resource to assign to the Nginx system task that runs on every client"
    type = object({
        cpu    = number
        memory = number
    })
    default = {
        cpu    = 200,
        memory = 256
    }
}