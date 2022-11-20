terraform {
  backend "consul" {
    path = "terraform/modules/digitalocean-vault/test"
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.11.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.24.0"
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
data "vault_kv_secret_v2" "do" {
  mount = var.do_kv_mount_path
  name  = "tokens"
}

provider "vault" {}
provider "digitalocean" {
  token = data.vault_kv_secret_v2.do.data["terraform"]
}

module "vpc" {
  source     = "brucellino/vpc/digitalocean"
  version    = "1.0.3"
  project    = var.project
  vpc_name   = "vault-test"
  vpc_region = "ams3"
}

module "cluster" {
  depends_on               = [module.vpc]
  source                   = "../../"
  vpc_name                 = "vault-test"
  project_name             = var.project.name
  ssh_inbound_source_cidrs = ["2.44.137.42"]
  auto_join_token          = data.vault_kv_secret_v2.do.data["autojoin_token"]
}
