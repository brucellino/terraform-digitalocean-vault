data "digitalocean_vpc" "vpc" {
  name = var.vpc_name
}

data "digitalocean_project" "p" {
  name = var.project_name
}

data "digitalocean_images" "ubuntu" {
  filter {
    key    = "slug"
    values = ["ubuntu-22-04-x64"]
  }
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

data "vault_kv_secret_v2" "cloudflare" {
  mount = "cloudflare"
  name  = "brusisceddu.xyz"
}

data "vault_kv_secret_v2" "do" {
  mount = var.do_vault_mount
  name  = "tokens"
}
resource "tls_private_key" "lb" {
  algorithm = "RSA"
}

# TLS cert for the load balancer
resource "tls_cert_request" "lb" {
  private_key_pem = tls_private_key.lb.private_key_pem

  subject {
    common_name  = "vault.brusisceddu.xyz"
    organization = "Cloudflare Managed CA for brucellino"
  }
}

resource "cloudflare_origin_ca_certificate" "lb" {
  # account_id         = data.cloudflare_accounts.example.id
  csr                = tls_cert_request.lb.cert_request_pem
  hostnames          = ["vault.brusisceddu.xyz"]
  request_type       = "origin-rsa"
  requested_validity = 7
}

resource "digitalocean_certificate" "cert" {
  name             = "vault-lb"
  type             = "custom"
  private_key      = tls_private_key.lb.private_key_pem
  leaf_certificate = cloudflare_origin_ca_certificate.lb.certificate
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
  name     = "vault-external"
  region   = var.region_from_data ? data.digitalocean_vpc.vpc.region : var.region
  vpc_uuid = data.digitalocean_vpc.vpc.id
  forwarding_rule {
    entry_port  = 443
    target_port = 8200
    #tfsec:ignore:digitalocean-compute-enforce-https
    entry_protocol   = "https"
    target_protocol  = "http"
    certificate_name = digitalocean_certificate.cert.name
  }

  healthcheck {
    # https://www.vaultproject.io/api-docs/system/health
    protocol               = "http"
    port                   = 8200
    path                   = "/v1/sys/health"
    check_interval_seconds = 10
    healthy_threshold      = 3
  }
  droplet_ids            = digitalocean_droplet.vault[*].id
  redirect_http_to_https = true
}

data "cloudflare_zones" "b" {
  # account_id = data.cloudflare_accounts.example.id
  filter {
    name = "brusisceddu.xyz"
  }
}

data "cloudflare_origin_ca_root_certificate" "rsa" {
  algorithm = "rsa"
}

resource "cloudflare_record" "vault" {
  zone_id = data.cloudflare_zones.b.zones[0].id
  name    = "vault"
  value   = digitalocean_loadbalancer.external.ip
  type    = "A"
  ttl     = 1
  proxied = false
}


resource "tls_private_key" "agent" {
  count     = var.instances
  algorithm = "RSA"
}

resource "tls_cert_request" "agent" {
  count           = var.instances
  private_key_pem = tls_private_key.agent[count.index].private_key_pem

  subject {
    common_name  = "vault-${count.index}.brusisceddu.xyz"
    organization = "Cloudflare Managed CA for brucellino"
  }
  dns_names    = ["vault-${count.index}.brusisceddu.xyz"]
  ip_addresses = ["127.0.0.1"]
}

resource "cloudflare_origin_ca_certificate" "agent" {
  count              = var.instances
  csr                = tls_cert_request.agent[count.index].cert_request_pem
  hostnames          = ["vault-${count.index}.brusisceddu.xyz"]
  request_type       = "origin-rsa"
  requested_validity = 7
}

resource "digitalocean_volume" "raft" {
  count                   = var.instances
  region                  = var.region_from_data ? data.digitalocean_vpc.vpc.region : var.region
  name                    = "vault-raft-${count.index}"
  size                    = 10
  initial_filesystem_type = "ext4"
  description             = "Vault Raft Data ${count.index}"
}

resource "digitalocean_droplet" "vault" {
  count         = var.instances
  image         = data.digitalocean_images.ubuntu.images[0].slug
  name          = "vault-${count.index}"
  region        = var.region_from_data ? data.digitalocean_vpc.vpc.region : var.region
  size          = var.droplet_size
  vpc_uuid      = data.digitalocean_vpc.vpc.id
  ipv6          = false
  backups       = false
  monitoring    = true
  tags          = ["vault", "auto-destroy"]
  ssh_keys      = [digitalocean_ssh_key.vault.id]
  droplet_agent = true
  volume_ids    = [digitalocean_volume.raft[count.index].id]
  connection {
    type = "ssh"
    user = "root"
    host = self.ipv4_address
  }

  provisioner "file" {
    content     = file("${path.module}/templates/vault.service")
    destination = "/etc/systemd/system/vault.service"
  }
  provisioner "remote-exec" {
    inline = ["mkdir -vp /etc/vault.d"]
  }
  provisioner "file" {
    content = templatefile("${path.module}/templates/vault.hcl.tftpl", {
      region         = var.region_from_data ? data.digitalocean_vpc.vpc.region : var.region
      tag_name       = "vault",
      autojoin_token = data.vault_kv_secret_v2.do.data["vault_auto_join"]
      node_id        = "vault-${tostring(count.index)}"
    })
    destination = "/etc/vault.d/vault.hcl"
  }

  provisioner "file" {
    content     = cloudflare_origin_ca_certificate.agent[count.index].certificate
    destination = "/etc/vault.d/vault-cert.pem"
  }
  provisioner "file" {
    content     = tls_cert_request.agent[count.index].private_key_pem
    destination = "/etc/vault.d/vault-key.pem"
  }
  provisioner "file" {
    content     = data.cloudflare_origin_ca_root_certificate.rsa.cert_pem
    destination = "/etc/vault.d/vault-ca.pem"
  }

  user_data = (templatefile(
    "${path.module}/templates/userdata.tftpl",
    {
      vault_version = var.vault_version,
      username      = var.username,
      ssh_pub_key   = data.http.ssh_key.response_body,
      volume_name   = digitalocean_volume.raft[count.index].name
    }
  ))
  lifecycle {
    create_before_destroy = true
  }
}

data "http" "ip" {
  url    = "http://canhazip.com"
  method = "GET"
}

resource "digitalocean_firewall" "ssh" {
  name        = replace("ssh-vault-${var.project_name}", " ", "-")
  droplet_ids = digitalocean_droplet.vault[*].id

  inbound_rule {
    protocol   = "tcp"
    port_range = "22"
    # source_addresses = var.ssh_inbound_source_cidrs
    source_addresses = [chomp(data.http.ip.response_body)]
  }

  outbound_rule {
    protocol   = "tcp"
    port_range = "1-65535"
    #tfsec:ignore:digitalocean-compute-no-public-egress
    destination_addresses = ["0.0.0.0/0"]
  }
}

resource "digitalocean_firewall" "vault" {
  name        = replace("vault-${var.project_name}", " ", "-")
  droplet_ids = digitalocean_droplet.vault[*].id

  inbound_rule {
    protocol                  = "tcp"
    port_range                = "8200-8201"
    source_load_balancer_uids = [digitalocean_loadbalancer.external.id]
    source_tags               = ["vault"]
  }
}

resource "digitalocean_project_resources" "vault" {
  project   = data.digitalocean_project.p.id
  resources = flatten([digitalocean_droplet.vault[*].urn, digitalocean_volume.raft[*].urn, digitalocean_loadbalancer.external.urn])
}

output "external_ips" {
  value = digitalocean_droplet.vault[*].ipv4_address
}
