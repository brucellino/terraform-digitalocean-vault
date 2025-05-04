terraform {
  required_version = "~> 1.9"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3"
    }
  }

}
