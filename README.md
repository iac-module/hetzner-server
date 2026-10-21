# hetzner-server
Hetzner Cloud server module: ssh key, firewall and server. Workload-specific setup (k3s, docker, ...) is passed in through `user_data`.

The ssh key and the firewall are each either **created** by the module or **reused** from the project:

| | create | reuse |
|---|---|---|
| ssh key | `create_ssh_key = true` (default) + `ssh_public_key` | `create_ssh_key = false` + `existing_ssh_key_names = ["..."]` |
| firewall | `create_firewall = true` (default) + `firewall_rules` | `create_firewall = false` + `existing_firewall_name = "..."` |

Hetzner rejects a second ssh key with the same public key, so reuse an existing key when it is already in the project.
Reused resources are looked up by name and are never modified or destroyed by this module.

Notes:
- `ssh_keys` and `user_data` are in `ignore_changes` of the server, since changing either replaces the server.
- The default `firewall_rules` open icmp/ssh/http/https to the whole internet. Restrict `source_ips` for anything but a lab.
- Auth: export a Read & Write project token as `HCLOUD_TOKEN`.

## Usage
```hcl
module "server" {
  source = "git::https://github.com/iac-module/hetzner-server.git?ref=v0.0.1"

  name           = "web-1"
  ssh_public_key = file("~/.ssh/id_ed25519.pub")

  # optional cloud-init, e.g. to install k3s
  user_data = <<-EOT
    #cloud-config
    runcmd:
      - curl -sfL https://get.k3s.io | sh -s - server
  EOT
}
```
See [examples](./examples).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.14 |
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | ~> 1.70 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | ~> 1.70 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [hcloud_firewall.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall) | resource |
| [hcloud_server.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_ssh_key.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key) | resource |
| [hcloud_firewall.existing](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/data-sources/firewall) | data source |
| [hcloud_ssh_key.existing](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/data-sources/ssh_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backups"></a> [backups](#input\_backups) | Enable Hetzner automatic backups (+20% of the server price). | `bool` | `false` | no |
| <a name="input_create_firewall"></a> [create\_firewall](#input\_create\_firewall) | Create a new firewall from firewall\_rules. Set to false to reuse existing\_firewall\_name (or run without a firewall). | `bool` | `true` | no |
| <a name="input_create_ssh_key"></a> [create\_ssh\_key](#input\_create\_ssh\_key) | Create a new hcloud ssh key from ssh\_public\_key. Set to false to reuse keys listed in existing\_ssh\_key\_names. | `bool` | `true` | no |
| <a name="input_delete_protection"></a> [delete\_protection](#input\_delete\_protection) | Protect the server from deletion and rebuild (the API requires both to match). | `bool` | `false` | no |
| <a name="input_existing_firewall_name"></a> [existing\_firewall\_name](#input\_existing\_firewall\_name) | Name of an existing hcloud firewall to attach to the server. Used when create\_firewall is false; it is attached in addition to the created one otherwise. | `string` | `null` | no |
| <a name="input_existing_ssh_key_names"></a> [existing\_ssh\_key\_names](#input\_existing\_ssh\_key\_names) | Names of existing hcloud ssh keys to attach to the server (in addition to the created one, if any). | `list(string)` | `[]` | no |
| <a name="input_firewall_name"></a> [firewall\_name](#input\_firewall\_name) | Name of the created firewall. Defaults to the value of name. | `string` | `null` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | Rules of the created firewall. The default opens icmp, ssh, http and https to the whole internet: restrict source\_ips for anything but a lab. | <pre>list(object({<br/>    description     = optional(string)<br/>    protocol        = string<br/>    port            = optional(string)<br/>    source_ips      = optional(list(string), [])<br/>    destination_ips = optional(list(string), [])<br/>    direction       = optional(string, "in")<br/>  }))</pre> | <pre>[<br/>  {<br/>    "description": "icmp",<br/>    "protocol": "icmp",<br/>    "source_ips": [<br/>      "0.0.0.0/0",<br/>      "::/0"<br/>    ]<br/>  },<br/>  {<br/>    "description": "ssh",<br/>    "port": "22",<br/>    "protocol": "tcp",<br/>    "source_ips": [<br/>      "0.0.0.0/0",<br/>      "::/0"<br/>    ]<br/>  },<br/>  {<br/>    "description": "http",<br/>    "port": "80",<br/>    "protocol": "tcp",<br/>    "source_ips": [<br/>      "0.0.0.0/0",<br/>      "::/0"<br/>    ]<br/>  },<br/>  {<br/>    "description": "https",<br/>    "port": "443",<br/>    "protocol": "tcp",<br/>    "source_ips": [<br/>      "0.0.0.0/0",<br/>      "::/0"<br/>    ]<br/>  }<br/>]</pre> | no |
| <a name="input_image"></a> [image](#input\_image) | Image name or ID (e.g. ubuntu-26.04, debian-13). | `string` | `"ubuntu-26.04"` | no |
| <a name="input_ipv4_enabled"></a> [ipv4\_enabled](#input\_ipv4\_enabled) | Assign a public IPv4 address. | `bool` | `true` | no |
| <a name="input_ipv6_enabled"></a> [ipv6\_enabled](#input\_ipv6\_enabled) | Assign a public IPv6 address. | `bool` | `true` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels applied to every created resource. | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of the server (fsn1, nbg1, hel1, ash, hil, sin). | `string` | `"fsn1"` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name used for the server and for the created ssh key / firewall (hostname: no underscores). | `string` | n/a | yes |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | ID of an existing private network to attach the server to. | `number` | `null` | no |
| <a name="input_network_ip"></a> [network\_ip](#input\_network\_ip) | Fixed private IP inside network\_id. Auto-assigned when null. | `string` | `null` | no |
| <a name="input_placement_group_id"></a> [placement\_group\_id](#input\_placement\_group\_id) | ID of an existing placement group. | `number` | `null` | no |
| <a name="input_server_type"></a> [server\_type](#input\_server\_type) | Hetzner server type (e.g. cax11 - ARM Ampere 2 vCPU / 4 GB, cx23, cpx22). | `string` | `"cax11"` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | Name of the created ssh key. Defaults to the value of name. | `string` | `null` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public key material for the new ssh key. Required when create\_ssh\_key is true. | `string` | `null` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Cloud-init user data (e.g. a #cloud-config document or a shell script). Changing it is ignored after creation, see the README. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_created_firewall_id"></a> [created\_firewall\_id](#output\_created\_firewall\_id) | ID of the created firewall, null when create\_firewall is false. |
| <a name="output_created_ssh_key_id"></a> [created\_ssh\_key\_id](#output\_created\_ssh\_key\_id) | ID of the created ssh key, null when create\_ssh\_key is false. |
| <a name="output_firewall_ids"></a> [firewall\_ids](#output\_firewall\_ids) | IDs of the firewalls attached to the server (created and existing). |
| <a name="output_ipv4_address"></a> [ipv4\_address](#output\_ipv4\_address) | Public IPv4 address of the server. |
| <a name="output_ipv6_address"></a> [ipv6\_address](#output\_ipv6\_address) | Public IPv6 address of the server. |
| <a name="output_ipv6_network"></a> [ipv6\_network](#output\_ipv6\_network) | Public IPv6 /64 network of the server. |
| <a name="output_server_id"></a> [server\_id](#output\_server\_id) | ID of the server. |
| <a name="output_server_name"></a> [server\_name](#output\_server\_name) | Name of the server. |
| <a name="output_ssh_key_ids"></a> [ssh\_key\_ids](#output\_ssh\_key\_ids) | IDs of the ssh keys attached to the server (created and existing). |
<!-- END_TF_DOCS -->
