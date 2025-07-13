terraform {
  backend "consul" {
    path = "terraform/modules/digitalocean-vault/test"
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2"
    }
    http = {
      source = "hashicorp/http"
    }
    tailscale = {
      source = "tailscale/tailscale"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

variable "do_kv_mount_path" {
  type    = string
  default = "digitalocean"
}

variable "project" {
  type = map(string)
  default = {
    description = "Vault Project"
    environment = "development"
    name        = "Vault module test"
    purpose     = "Personal"
    is_default  = false
  }
}

variable "vpc_name" {
  type    = string
  default = "vault-test"
}
data "vault_kv_secret_v2" "do" {
  mount = var.do_kv_mount_path
  name  = "tokens"
}

data "vault_kv_secret_v2" "tailscale" {
  mount = var.do_kv_mount_path
  name  = "tailscale"
}

provider "vault" {}

provider "digitalocean" {
  token = data.vault_kv_secret_v2.do.data["terraform"]
}

provider "tailscale" {
  api_key = data.vault_kv_secret_v2.tailscale.data.api_key
}
data "http" "ip" {
  url = "https://api.ipify.org?format=json"
}

locals {
  addr = jsondecode(data.http.ip.response_body).ip
}

module "vpc" {
  source          = "brucellino/vpc/digitalocean"
  version         = "2.0.0"
  project         = var.project
  vpc_name        = var.vpc_name
  vpc_region      = "ams3"
  vpc_description = "Vault VPC"
}

module "cluster" {
  create_instances         = true
  instances                = 3
  depends_on               = [module.vpc]
  source                   = "../../"
  vpc_name                 = var.vpc_name
  project_name             = var.project.name
  ssh_inbound_source_cidrs = [local.addr]
  region_from_data         = false
  region                   = "ams3"
  auto_join_token          = data.vault_kv_secret_v2.do.data["vault_auto_join"]
}
