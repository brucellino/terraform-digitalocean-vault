data "digitalocean_vpc" "vpc" {
  name = var.vpc_name
}

data "digitalocean_project" "p" {
  name = var.project_name
}

data "digitalocean_images" "ubuntu" {
  filter {
    key    = "slug"
    values = ["ubuntu-24-04-x64"]
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

data "vault_kv_secret_v2" "do" {
  mount = var.do_vault_mount
  name  = "tokens"
}

data "tailscale_device" "hah_vault" {
  name = "sense.orca-ordinal.ts.net"
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

resource "digitalocean_volume" "raft" {
  count                   = var.instances
  region                  = var.region_from_data ? data.digitalocean_vpc.vpc.region : var.region
  name                    = "vault-raft-${count.index}"
  size                    = var.raft_size
  initial_filesystem_type = "ext4"
  description             = "Vault Raft Data ${count.index}"
}

resource "tailscale_tailnet_key" "vault" {
  description   = "Tailnet key for vault instances in digitalocean"
  reusable      = true
  preauthorized = true
  ephemeral     = true
  expiry        = 0
}

# resource "tailscale_acl" "vault_operator" {
#   acl = jsonencode({
#     acls : [
#       {
#         // Allow admin group to access vault service on do.
#         action = "accept",
#         users = ["autogroup:admin"]
#       }
#     ],
#     ssh : [
# 		{
# 			action = "accept",
# 			src: ["autogroup:admin"],
# 			dst: ["tag:digitalocean"],
# 			users: ["root"]
# 		}
# 	]
#   })
# }
resource "vault_token" "unseal" {
  display_name = "unseal-token"
  period       = "2h"
  ttl          = "24h"
  no_parent    = true
  policies     = ["autounseal"]
}

resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = resource.tls_private_key.ca.private_key_pem
  subject {
    common_name         = "Org Root CA"
    country             = "IT"
    organization        = "Org"
    organizational_unit = "Cloud Native Root CA"
  }
  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "client_auth",
    "server_auth",
    "digital_signature"
  ]
  is_ca_certificate     = true
  validity_period_hours = 8760
}

resource "digitalocean_droplet" "vault" {
  count         = var.create_instances ? var.instances : 0
  image         = data.digitalocean_images.ubuntu.images[0].slug
  name          = "vault-${count.index}"
  region        = var.region_from_data ? data.digitalocean_vpc.vpc.region : var.region
  size          = var.droplet_size
  vpc_uuid      = data.digitalocean_vpc.vpc.id
  ipv6          = false
  backups       = false
  monitoring    = true
  tags          = ["vault", "auto-destroy", "ssh"]
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
      region                   = var.region_from_data ? data.digitalocean_vpc.vpc.region : var.region
      tag_name                 = "vault",
      autojoin_token           = data.vault_kv_secret_v2.do.data["vault_auto_join"],
      node_id                  = "vault-${tostring(count.index)}",
      raft_storage_mount_point = "/mnt/vault",
      vault_addr               = data.tailscale_device.hah_vault.addresses[0],
      unseal_token             = vault_token.unseal.client_token
    })
    destination = "/etc/vault.d/vault.hcl"
  }
  user_data = (templatefile(
    "${path.module}/templates/userdata.tftpl",
    {
      tailscale_hostname = "vault-${count.index}"
      vault_version      = var.vault_version,
      username           = var.username,
      ssh_pub_key        = data.http.ssh_key.response_body,
      volume_name        = digitalocean_volume.raft[count.index].name
      tailscale_key      = tailscale_tailnet_key.vault.key
    }
  ))
}

# certs depend on instance IPs once assigned
resource "tls_private_key" "instance" {
  count     = var.create_instances ? var.instances : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "instance" {
  count           = var.create_instances ? var.instances : 0
  private_key_pem = resource.tls_private_key.instance[count.index].private_key_pem
  subject {
    common_name         = "vault-${count.index}"
    country             = "IT"
    organization        = "Org"
    organizational_unit = "Cloud Native Root CA"
  }
  ip_addresses = ["127.0.0.1", digitalocean_droplet.vault[count.index].ipv4_address, digitalocean_droplet.vault[count.index].ipv4_address_private]
}

resource "tls_locally_signed_cert" "instance" {
  count                 = var.create_instances ? var.instances : 0
  cert_request_pem      = tls_cert_request.instance[count.index].cert_request_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 8760
  allowed_uses          = ["server_auth", "client_auth"]
}

resource "null_resource" "certs" {
  count = var.create_instances ? var.instances : 0
  connection {
    host        = digitalocean_droplet.vault[count.index].ipv4_address
    user        = "root"
    private_key = file("/home/becker/.ssh/id_rsa")
  }

  provisioner "file" {
    content     = trimspace(tls_locally_signed_cert.instance[count.index].cert_pem)
    destination = "/etc/vault.d/vault-cert.pem"
  }

  provisioner "file" {
    content     = tls_private_key.instance[count.index].private_key_pem
    destination = "/etc/vault.d/vault-key.pem"
  }

  provisioner "file" {
    content     = tls_self_signed_cert.ca.cert_pem
    destination = "/etc/vault.d/vault-ca.pem"
  }
}

resource "digitalocean_firewall" "ssh" {
  name        = "ssh-from-home"
  droplet_ids = [for i in digitalocean_droplet.vault : i.id]
  tags        = ["ssh"]
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.ssh_inbound_source_cidrs
  }
}

resource "digitalocean_firewall" "closed" {
  name = "everything-closed"

  droplet_ids = [for i in digitalocean_droplet.vault : i.id]
  tags        = ["vault"]

  # SSH closed from everywhere, it will only be allowed in tailscale.
  # instances can communicate with each other on private network
  inbound_rule {
    protocol           = "tcp"
    port_range         = "1-65535"
    source_droplet_ids = [for i in digitalocean_droplet.vault : i.id]
  }

  outbound_rule {
    protocol                = "tcp"
    port_range              = "1-65535"
    destination_droplet_ids = [for i in digitalocean_droplet.vault : i.id]
  }

  # allow outbound http and https connections
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"] #tfsec:ignore:digitalocean-compute-no-public-egress
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"] #tfsec:ignore:digitalocean-compute-no-public-egress
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"] #tfsec:ignore:digitalocean-compute-no-public-ingress
  }

  # Allow DNS lookups
  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"] #tfsec:ignore:digitalocean-compute-no-public-egress
  }

  # Allow UDP from anywhere
  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"] #tfsec:ignore:digitalocean-compute-no-public-egress
  }
}

resource "digitalocean_project_resources" "vault" {
  project    = data.digitalocean_project.p.id
  resources  = flatten([digitalocean_droplet.vault[*].urn, digitalocean_volume.raft[*].urn])
  depends_on = [digitalocean_volume.raft, digitalocean_droplet.vault]
}

output "external_ips" {
  value = digitalocean_droplet.vault[*].ipv4_address
}
