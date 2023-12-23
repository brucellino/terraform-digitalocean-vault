[![main](https://github.com/brucellino/terraform-digitalocean-vault/actions/workflows/release.yml/badge.svg?branch=main)](https://github.com/brucellino/terraform-digitalocean-vault/actions/workflows/release.yml) [![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit) [![pre-commit.ci status](https://results.pre-commit.ci/badge/github/brucellino/terraform-digitalocean-vault/main.svg)](https://results.pre-commit.ci/latest/github/brucellino/terraform-digitalocean-vault/main) [![semantic-release: conventional](https://img.shields.io/badge/semantic--release-conventional-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)

# Terraform Module Vault on DigitalOcean

## Pre-commit hooks

<!-- Edit this section or delete if you make no change  -->

The [pre-commit](https://pre-commit.com) framework is used to manage pre-commit hooks for this repository.
A few well-known hooks are provided to cover correctness, security and safety in terraform.

## Examples

The `examples/` directory contains the example usage of this module.
These examples show how to use the module in your project, and are also use for testing in CI/CD.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >1.2.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >= 4.1.0 |
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | >= 2.21.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.2.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 4.19.0 |
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.34.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.5 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 3.13.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_origin_ca_certificate.agent](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/origin_ca_certificate) | resource |
| [cloudflare_origin_ca_certificate.lb](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/origin_ca_certificate) | resource |
| [cloudflare_record.vault](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [digitalocean_certificate.cert](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/certificate) | resource |
| [digitalocean_droplet.vault](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet) | resource |
| [digitalocean_firewall.ssh](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/firewall) | resource |
| [digitalocean_firewall.vault](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/firewall) | resource |
| [digitalocean_loadbalancer.external](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/loadbalancer) | resource |
| [digitalocean_project_resources.vault](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/project_resources) | resource |
| [digitalocean_ssh_key.vault](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/ssh_key) | resource |
| [digitalocean_volume.raft](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/volume) | resource |
| [tls_cert_request.agent](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_cert_request.lb](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_private_key.agent](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.lb](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [cloudflare_origin_ca_root_certificate.rsa](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/origin_ca_root_certificate) | data source |
| [cloudflare_zones.b](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zones) | data source |
| [digitalocean_images.ubuntu](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/images) | data source |
| [digitalocean_project.p](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/project) | data source |
| [digitalocean_vpc.vpc](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/vpc) | data source |
| [http_http.ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [http_http.ssh_key](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [vault_kv_secret_v2.cloudflare](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/kv_secret_v2) | data source |
| [vault_kv_secret_v2.do](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/kv_secret_v2) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_join_token"></a> [auto\_join\_token](#input\_auto\_join\_token) | Digital Ocean autojoin token | `string` | `""` | no |
| <a name="input_do_vault_mount"></a> [do\_vault\_mount](#input\_do\_vault\_mount) | Name of the mount where the digital ocean token for autodiscovery is found | `string` | `"digitalocean"` | no |
| <a name="input_droplet_size"></a> [droplet\_size](#input\_droplet\_size) | Size of the droplet for Vault instances | `string` | `"s-1vcpu-1gb"` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | number of instances in the vault cluster | `number` | `3` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project to find | `string` | `"My Project"` | no |
| <a name="input_region"></a> [region](#input\_region) | Name of Digital Ocean region we are using. | `string` | `"ams3"` | no |
| <a name="input_region_from_data"></a> [region\_from\_data](#input\_region\_from\_data) | Look up region data from vpc data. | `bool` | `false` | no |
| <a name="input_ssh_inbound_source_cidrs"></a> [ssh\_inbound\_source\_cidrs](#input\_ssh\_inbound\_source\_cidrs) | List of CIDRs from which we will allow ssh connections on port 22 | `list(any)` | `[]` | no |
| <a name="input_ssh_public_key_url"></a> [ssh\_public\_key\_url](#input\_ssh\_public\_key\_url) | URL of of the public ssh key to add to the droplet | `string` | `"https://github.com/brucellino.keys"` | no |
| <a name="input_username"></a> [username](#input\_username) | Name of the non-root user to add | `string` | `"hashiuser"` | no |
| <a name="input_vault_version"></a> [vault\_version](#input\_vault\_version) | Version of Vault that we want to deploy | `string` | `"1.14.0"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC we are using | `string` | `"My VPC"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_droplet_ip_addresses"></a> [droplet\_ip\_addresses](#output\_droplet\_ip\_addresses) | n/a |
| <a name="output_external_ips"></a> [external\_ips](#output\_external\_ips) | n/a |
<!-- END_TF_DOCS -->
