variable "do_vault_mount" {
  type        = string
  description = "Name of the mount where the digital ocean token for autodiscovery is found"
  default     = "digitalocean"
}

variable "project_name" {
  type        = string
  description = "Name of the project to find"
  default     = "HashiDo"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC we are using"
  default     = "hashi"
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
  default     = "s-2vcpu-2gb"
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
  default     = "1.19.3"
  description = "Version of Vault that we want to deploy"
}

variable "auto_join_token" {
  type        = string
  description = "Digital Ocean autojoin token"
  default     = ""
  sensitive   = true
}

variable "raft_size" {
  type        = number
  default     = 1
  description = "Size of the block storage provisioned for raft storage"
}

variable "create_instances" {
  type        = bool
  default     = false
  description = "Toggle to decide whether to create instances or not"
}

variable "deploy_zone" {
  type        = string
  description = "name of the zone which will be used to deploy the cluster into. This must already exist on cloudflare in your account."
  default     = "brusisceddu.xyz"
}
