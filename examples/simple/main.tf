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
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
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

provider "vault" {}

data "vault_kv_secret_v2" "do" {
  mount = var.do_kv_mount_path
  name  = "tokens"
}

data "vault_kv_secret_v2" "tailscale" {
  mount = "hashiatho.me-v2"
  name  = "tailscale"
}

provider "digitalocean" {
  token = data.vault_kv_secret_v2.do.data["terraform"]
}

provider "tailscale" {
  api_key = data.vault_kv_secret_v2.tailscale.data.tailscale_api_token
}
data "http" "ip" {
  url = "https://api.ipify.org?format=json"
}

locals {
  addr = jsondecode(data.http.ip.response_body).ip
}

module "vpc" {
  source          = "brucellino/vpc/digitalocean"
  version         = "~> 2"
  project         = var.project
  vpc_name        = var.vpc_name
  vpc_region      = "ams3"
  vpc_description = "Vault VPC"
}

# use a sleep resource to sleep for 30 seconds before destroying vpc
resource "time_sleep" "wait_after_destroy" {
  depends_on       = [module.vpc]
  destroy_duration = "30s"
}

module "cluster" {
  depends_on               = [time_sleep.wait_after_destroy, module.vpc]
  create_instances         = true
  instances                = 3
  source                   = "../../"
  vpc_name                 = var.vpc_name
  project_name             = var.project.name
  ssh_inbound_source_cidrs = [local.addr]
  region_from_data         = false
  region                   = "ams3"
  ssh_private_key_path     = "~/.ssh/id_rsa"
  auto_join_token          = data.vault_kv_secret_v2.do.data["vault_auto_join"]
}
