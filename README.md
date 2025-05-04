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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | >= 2 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3 |
| <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) | ~> 0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.52.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.5.0 |
| <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) | 0.19.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 3.13.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_droplet.vault](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet) | resource |
| [digitalocean_firewall.closed](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/firewall) | resource |
| [digitalocean_project_resources.vault](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/project_resources) | resource |
| [digitalocean_ssh_key.vault](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/ssh_key) | resource |
| [digitalocean_volume.raft](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/volume) | resource |
| [tailscale_tailnet_key.vault](https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/tailnet_key) | resource |
| [vault_token.unseal](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/token) | resource |
| [digitalocean_images.ubuntu](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/images) | data source |
| [digitalocean_project.p](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/project) | data source |
| [digitalocean_vpc.vpc](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/vpc) | data source |
| [http_http.ssh_key](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [tailscale_device.hah_vault](https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/data-sources/device) | data source |
| [vault_kv_secret_v2.do](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/kv_secret_v2) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_join_token"></a> [auto\_join\_token](#input\_auto\_join\_token) | Digital Ocean autojoin token | `string` | `""` | no |
| <a name="input_create_instances"></a> [create\_instances](#input\_create\_instances) | Toggle to decide whether to create instances or not | `bool` | `false` | no |
| <a name="input_deploy_zone"></a> [deploy\_zone](#input\_deploy\_zone) | name of the zone which will be used to deploy the cluster into. This must already exist on cloudflare in your account. | `string` | `"brusisceddu.xyz"` | no |
| <a name="input_do_vault_mount"></a> [do\_vault\_mount](#input\_do\_vault\_mount) | Name of the mount where the digital ocean token for autodiscovery is found | `string` | `"digitalocean"` | no |
| <a name="input_droplet_size"></a> [droplet\_size](#input\_droplet\_size) | Size of the droplet for Vault instances | `string` | `"s-2vcpu-2gb"` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | number of instances in the vault cluster | `number` | `3` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project to find | `string` | `"HashiDo"` | no |
| <a name="input_raft_size"></a> [raft\_size](#input\_raft\_size) | Size of the block storage provisioned for raft storage | `number` | `1` | no |
| <a name="input_region"></a> [region](#input\_region) | Name of Digital Ocean region we are using. | `string` | `"ams3"` | no |
| <a name="input_region_from_data"></a> [region\_from\_data](#input\_region\_from\_data) | Look up region data from vpc data. | `bool` | `false` | no |
| <a name="input_ssh_inbound_source_cidrs"></a> [ssh\_inbound\_source\_cidrs](#input\_ssh\_inbound\_source\_cidrs) | List of CIDRs from which we will allow ssh connections on port 22 | `list(any)` | `[]` | no |
| <a name="input_ssh_public_key_url"></a> [ssh\_public\_key\_url](#input\_ssh\_public\_key\_url) | URL of of the public ssh key to add to the droplet | `string` | `"https://github.com/brucellino.keys"` | no |
| <a name="input_username"></a> [username](#input\_username) | Name of the non-root user to add | `string` | `"hashiuser"` | no |
| <a name="input_vault_version"></a> [vault\_version](#input\_vault\_version) | Version of Vault that we want to deploy | `string` | `"1.19.3"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC we are using | `string` | `"hashi"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_droplet_ip_addresses"></a> [droplet\_ip\_addresses](#output\_droplet\_ip\_addresses) | n/a |
| <a name="output_external_ips"></a> [external\_ips](#output\_external\_ips) | n/a |
<!-- END_TF_DOCS -->
