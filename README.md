[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit) [![pre-commit.ci status](https://results.pre-commit.ci/badge/github/brucellino/terraform-module-digitalocean-vault/main.svg)](https://results.pre-commit.ci/latest/github/brucellino/terraform-module-digitalocean-vault/main) [![semantic-release: conventional](https://img.shields.io/badge/semantic--release-conventional-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)

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
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | >=2.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.24.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_droplet.vault](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet) | resource |
| [digitalocean_firewall.ssh](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/firewall) | resource |
| [digitalocean_firewall.vault](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/firewall) | resource |
| [digitalocean_loadbalancer.external](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/loadbalancer) | resource |
| [digitalocean_project_resources.network](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/project_resources) | resource |
| [digitalocean_project_resources.vault_droplets](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/project_resources) | resource |
| [digitalocean_ssh_key.vault](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/ssh_key) | resource |
| [digitalocean_images.ubuntu](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/images) | data source |
| [digitalocean_project.p](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/project) | data source |
| [digitalocean_vpc.vpc](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/vpc) | data source |
| [http_http.ssh_key](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_droplet_size"></a> [droplet\_size](#input\_droplet\_size) | Size of the droplet for Vault instances | `string` | `"s-1vcpu-1gb"` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | number of instances in the vault cluster | `number` | `3` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project to find | `string` | `"My Project"` | no |
| <a name="input_ssh_inbound_source_cidrs"></a> [ssh\_inbound\_source\_cidrs](#input\_ssh\_inbound\_source\_cidrs) | List of CIDRs from which we will allow ssh connections on port 22 | `list(any)` | `[]` | no |
| <a name="input_ssh_public_key_url"></a> [ssh\_public\_key\_url](#input\_ssh\_public\_key\_url) | URL of of the public ssh key to add to the droplet | `string` | `"https://github.com/brucellino.keys"` | no |
| <a name="input_username"></a> [username](#input\_username) | Name of the non-root user to add | `string` | `"hashiuser"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC we are using | `string` | `"My VPC"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_droplet_ip_addresses"></a> [droplet\_ip\_addresses](#output\_droplet\_ip\_addresses) | n/a |
| <a name="output_external_ips"></a> [external\_ips](#output\_external\_ips) | n/a |
<!-- END_TF_DOCS -->
