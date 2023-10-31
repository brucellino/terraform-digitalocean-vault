terraform {
  backend "consul" {
    path = "terraform/modules/digitalocean-vault/test"
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.11"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.24"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.1"
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

provider "vault" {}
provider "digitalocean" {
  token = data.vault_kv_secret_v2.do.data["terraform"]
}
data "vault_kv_secret_v2" "cloudflare" {
  mount = "cloudflare"
  name  = "brusisceddu.xyz"
}
provider "cloudflare" {
  api_token = data.vault_kv_secret_v2.cloudflare.data["api_token"]
}


module "vpc" {
  source     = "brucellino/vpc/digitalocean"
  version    = "1.0.3"
  project    = var.project
  vpc_name   = var.vpc_name
  vpc_region = "ams3"
}

module "cluster" {
  depends_on               = [module.vpc]
  source                   = "../../"
  vault_version            = "1.6.2"
  vpc_name                 = var.vpc_name
  project_name             = var.project.name
  ssh_inbound_source_cidrs = ["2.38.151.8"]
  auto_join_token          = data.vault_kv_secret_v2.do.data["vault_auto_join"]
  region_from_data         = false
  region                   = "ams3"
}
