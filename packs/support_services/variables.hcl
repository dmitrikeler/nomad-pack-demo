variable "job_name" {
    description = "The name to use as the job name which overrides using the pack name"
    type        = string
    default     = "support-services"
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

variable "docker_image" {
    description = "The docker image version"
    type        = string
    default     = "vault:latest"
}

variable "gonsul_repo_url" {
    description = "Gonsul repo URL"
    type        = string
    default     = ""
}

variable "gonsul_private_key" {
    description = "Gonsul repo SSH private key"
    type        = string
    default     = ""
}

variable "vault_log_level" {
    description = "Gonsul repo SSH private key"
    type        = string
    default     = "warn"
}

variable "vault_ui_url" {
    description = "Vault UI URL"
    type        = string
    default     = "vault.local"
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