# Example for deploying vault into an existing Digital ocean VPC
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0"
    }
  }
  backend "consul" {
    path = "terraform/modules/digitalocean-vault/existing-vpc"
  }
}
# We will still need to look up the digital ocean token from vault@home
provider "vault" {
  alias   = "athome"
  address = "http://active.vault.service.consul:8200"
}

data "vault_kv_secret_v2" "do" {
  provider = vault.athome
  mount    = "digitalocean"
  name     = "tokens"
}

data "vault_kv_secret_v2" "ts" {
  provider = vault.athome
  mount    = "digitalocean"
  name     = "tailscale"
}

provider "digitalocean" {
  token = data.vault_kv_secret_v2.do.data.terraform
}

provider "tailscale" {
  api_key = data.vault_kv_secret_v2.ts.data.api_key
  tailnet = "brucellino.github"
}

data "digitalocean_vpc" "vpc" {
  name = "hashi"
}

module "vault" {
  source           = "../../"
  instances        = 3
  create_instances = true
}
