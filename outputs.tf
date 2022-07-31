output "droplet_ip_addresses" {
  value = digitalocean_droplet.vault[*].ipv4_address
}
