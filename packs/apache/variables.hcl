variable "job_name" {
    description = "The name to use as the job name which overrides using the pack name"
    type        = string
    default     = "apache"
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

variable "register_service" {
  description = "If you want to register a consul service for the job"
  type        = bool
  default     = true
}

variable "service_name" {
    description = "The consul service you wish to load balance"
    type        = string
    default     = "apache"
}

variable "docker_username" {
    description = "Docker username"
    type        = string
    default     = "docker"
}

variable "docker_password" {
    description = "Docker password"
    type        = string
    default     = ""
}

variable "image" {
    description = "The docker image version"
    type        = string
    default     = "docker-new.finnplay.net/dev/nomad-app"
}

variable "version_tag" {
    description = "The docker image version"
    type        = string
    default     = "4.2"
}

variable "vault_token" {
    description = "Authentication token for Vault integration"
    type        = string
    default     = ""
}

variable "http_port" {
    description = "The Nomad client port that routes to the Nginx. This port will be where you visit your load balanced application"
    type        = number
    default     = 8888
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