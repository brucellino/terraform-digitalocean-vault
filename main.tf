terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.21.0"
    }
  }
}

data "digitalocean_vpc" "vpc" {
  name = var.vpc_name
}

data "digitalocean_project" "p" {
  name = var.project_name
}

data "digitalocean_images" "ubuntu" {
  filter {
    key    = "distribution"
    values = ["Ubuntu"]
  }
  filter {
    key    = "regions"
    values = [data.digitalocean_vpc.vpc.region]
  }
  sort {
    key       = "created"
    direction = "desc"
  }
}

data "http" "ssh_key" {
  url = var.ssh_public_key_url
}

resource "digitalocean_certificate" "cert" {
  name    = "vault_external"
  type    = "lets_encrypt"
  domains = ["hashi"]
}

resource "digitalocean_ssh_key" "vault" {
  name       = "Vault ssh key"
  public_key = data.http.ssh_key.response_body
  lifecycle {
    precondition {
      condition     = contains([201, 200, 204], data.http.ssh_key.status_code)
      error_message = "Status code is not OK"
    }
  }
}

resource "digitalocean_loadbalancer" "external" {
  name   = "vault_external"
  region = data.digitalocean_vpc.vpc.region
  # forwarding_rule {
  #   entry_port      = 80
  #   target_port     = 8200
  #   entry_protocol  = "http"
  #   target_protocol = "http"
  # }

  forwarding_rule {
    entry_port      = 443
    target_port     = 8200
    entry_protocol  = "https"
    target_protocol = "http"
  }

}

resource "digitalocean_droplet" "vault" {
  count         = var.instances
  image         = data.digitalocean_images.ubuntu.images[0].slug
  name          = "vault-${count.index}"
  region        = data.digitalocean_vpc.vpc.region
  size          = var.droplet_size
  vpc_uuid      = data.digitalocean_vpc.vpc.id
  ipv6          = false
  backups       = false
  monitoring    = true
  tags          = ["vault"]
  ssh_keys      = [digitalocean_ssh_key.vault.id]
  droplet_agent = true
  user_data = templatefile(
    "${path.module}/templates/userdata.tmpl",
    {
      vault_version = "1.11.0",
      username      = var.username,
      ssh_pubkey    = data.http.ssh_key.body
    }
  )
}

resource "digitalocean_firewall" "ssh" {
  name        = "ssh"
  droplet_ids = digitalocean_droplet.vault[*].id

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.ssh_inbound_source_cidrs
  }
}

resource "digitalocean_firewall" "vault" {
  name        = "vault"
  droplet_ids = digitalocean_droplet.vault[*].id

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = []
  }
}

resource "digitalocean_project_resources" "vault_droplets" {
  project   = data.digitalocean_project.p.id
  resources = digitalocean_droplet.vault[*].urn
}
