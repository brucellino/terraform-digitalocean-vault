variable "do_vault_mount" {
  type        = string
  description = "Name of the mount where the digital ocean token for autodiscovery is found"
  default     = "digitalocean"
}

variable "project_name" {
  type        = string
  description = "Name of the project to find"
  default     = "My Project"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC we are using"
  default     = "My VPC"
}

variable "region" {
  type        = string
  description = "Name of Digital Ocean region we are using."
  default     = "ams3"
}

variable "region_from_data" {
  type        = bool
  description = "Look up region data from vpc data."
  default     = false
}

variable "droplet_size" {
  type        = string
  description = "Size of the droplet for Vault instances"
  default     = "s-1vcpu-1gb"
}

variable "ssh_public_key_url" {
  type        = string
  description = "URL of of the public ssh key to add to the droplet"
  default     = "https://github.com/brucellino.keys"
}

variable "instances" {
  type        = number
  description = "number of instances in the vault cluster"
  default     = 3
}

variable "username" {
  type        = string
  description = "Name of the non-root user to add"
  default     = "hashiuser"
}

variable "ssh_inbound_source_cidrs" {
  type        = list(any)
  description = "List of CIDRs from which we will allow ssh connections on port 22"
  default     = []
}

variable "vault_version" {
  type        = string
  default     = "1.14.0"
  description = "Version of Vault that we want to deploy"
}

variable "auto_join_token" {
  type        = string
  description = "Digital Ocean autojoin token"
  default     = ""
  sensitive   = true
}
