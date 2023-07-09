# Use this file to declare the terraform configuration
# Add things like:
# - required version
# - required providers
# Do not add things like:
# - provider configuration
# - backend configuration
# These will be declared in the terraform document which consumes the module.

terraform {
  required_version = ">1.2.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">=2.21.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">=4.0.4"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.1.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.2.0"
    }
  }

}
