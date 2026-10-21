variable "name" {
  type        = string
  description = "Base name used for the server and for the created ssh key / firewall (hostname: no underscores)."
}

variable "labels" {
  type        = map(string)
  description = "Labels applied to every created resource."
  default     = {}
}

###############################################################################
# SSH key
###############################################################################
variable "create_ssh_key" {
  type        = bool
  description = "Create a new hcloud ssh key from ssh_public_key. Set to false to reuse keys listed in existing_ssh_key_names."
  default     = true
}

variable "ssh_public_key" {
  type        = string
  description = "Public key material for the new ssh key. Required when create_ssh_key is true."
  default     = null

  validation {
    condition     = !var.create_ssh_key || var.ssh_public_key != null
    error_message = "ssh_public_key must be set when create_ssh_key is true."
  }
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the created ssh key. Defaults to the value of name."
  default     = null
}

variable "existing_ssh_key_names" {
  type        = list(string)
  description = "Names of existing hcloud ssh keys to attach to the server (in addition to the created one, if any)."
  default     = []

  validation {
    condition     = var.create_ssh_key || length(var.existing_ssh_key_names) > 0
    error_message = "Set create_ssh_key = true or provide at least one name in existing_ssh_key_names."
  }
}

###############################################################################
# Firewall
###############################################################################
variable "create_firewall" {
  type        = bool
  description = "Create a new firewall from firewall_rules. Set to false to reuse existing_firewall_name (or run without a firewall)."
  default     = true
}

variable "firewall_name" {
  type        = string
  description = "Name of the created firewall. Defaults to the value of name."
  default     = null
}

variable "firewall_rules" {
  type = list(object({
    description     = optional(string)
    protocol        = string
    port            = optional(string)
    source_ips      = optional(list(string), [])
    destination_ips = optional(list(string), [])
    direction       = optional(string, "in")
  }))
  description = "Rules of the created firewall. The default opens icmp, ssh, http and https to the whole internet: restrict source_ips for anything but a lab."
  default = [
    { description = "icmp", protocol = "icmp", source_ips = ["0.0.0.0/0", "::/0"] },
    { description = "ssh", protocol = "tcp", port = "22", source_ips = ["0.0.0.0/0", "::/0"] },
    { description = "http", protocol = "tcp", port = "80", source_ips = ["0.0.0.0/0", "::/0"] },
    { description = "https", protocol = "tcp", port = "443", source_ips = ["0.0.0.0/0", "::/0"] },
  ]

  validation {
    condition     = alltrue([for r in var.firewall_rules : contains(["in", "out"], r.direction)])
    error_message = "direction must be \"in\" or \"out\"."
  }
}

variable "existing_firewall_name" {
  type        = string
  description = "Name of an existing hcloud firewall to attach to the server. Used when create_firewall is false; it is attached in addition to the created one otherwise."
  default     = null
}

###############################################################################
# Server
###############################################################################
variable "server_type" {
  type        = string
  description = "Hetzner server type (e.g. cax11 - ARM Ampere 2 vCPU / 4 GB, cx23, cpx22)."
  default     = "cax11"
}

variable "image" {
  type        = string
  description = "Image name or ID (e.g. ubuntu-26.04, debian-13)."
  default     = "ubuntu-26.04"
}

variable "location" {
  type        = string
  description = "Location of the server (fsn1, nbg1, hel1, ash, hil, sin)."
  default     = "fsn1"
}

variable "backups" {
  type        = bool
  description = "Enable Hetzner automatic backups (+20% of the server price)."
  default     = false
}

variable "ipv4_enabled" {
  type        = bool
  description = "Assign a public IPv4 address."
  default     = true
}

variable "ipv6_enabled" {
  type        = bool
  description = "Assign a public IPv6 address."
  default     = true
}

variable "delete_protection" {
  type        = bool
  description = "Protect the server from deletion and rebuild (the API requires both to match)."
  default     = false
}

variable "placement_group_id" {
  type        = number
  description = "ID of an existing placement group."
  default     = null
}

variable "network_id" {
  type        = number
  description = "ID of an existing private network to attach the server to."
  default     = null
}

variable "network_ip" {
  type        = string
  description = "Fixed private IP inside network_id. Auto-assigned when null."
  default     = null
}

###############################################################################
# cloud-init
###############################################################################
variable "user_data" {
  type        = string
  description = "Cloud-init user data (e.g. a #cloud-config document or a shell script). Changing it is ignored after creation, see the README."
  default     = null
}
