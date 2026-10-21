locals {
  ssh_key_name  = coalesce(var.ssh_key_name, var.name)
  firewall_name = coalesce(var.firewall_name, var.name)

  ssh_key_ids = concat(
    hcloud_ssh_key.this[*].id,
    [for k in data.hcloud_ssh_key.existing : k.id],
  )

  firewall_ids = concat(
    hcloud_firewall.this[*].id,
    data.hcloud_firewall.existing[*].id,
  )
}

###############################################################################
# SSH key
###############################################################################
resource "hcloud_ssh_key" "this" {
  count = var.create_ssh_key ? 1 : 0

  name       = local.ssh_key_name
  public_key = var.ssh_public_key
  labels     = var.labels
}

data "hcloud_ssh_key" "existing" {
  for_each = toset(var.existing_ssh_key_names)

  name = each.value
}

###############################################################################
# Firewall
###############################################################################
resource "hcloud_firewall" "this" {
  count = var.create_firewall ? 1 : 0

  name   = local.firewall_name
  labels = var.labels

  dynamic "rule" {
    for_each = var.firewall_rules
    content {
      direction       = rule.value.direction
      description     = rule.value.description
      protocol        = rule.value.protocol
      port            = rule.value.port
      source_ips      = rule.value.direction == "in" ? rule.value.source_ips : null
      destination_ips = rule.value.direction == "out" ? rule.value.destination_ips : null
    }
  }
}

data "hcloud_firewall" "existing" {
  count = var.existing_firewall_name != null ? 1 : 0

  name = var.existing_firewall_name
}

###############################################################################
# Server
###############################################################################
resource "hcloud_server" "this" {
  name               = var.name
  server_type        = var.server_type
  image              = var.image
  location           = var.location
  ssh_keys           = local.ssh_key_ids
  firewall_ids       = local.firewall_ids
  backups            = var.backups
  placement_group_id = var.placement_group_id
  delete_protection  = var.delete_protection
  rebuild_protection = var.delete_protection
  labels             = var.labels
  user_data          = var.user_data

  public_net {
    ipv4_enabled = var.ipv4_enabled
    ipv6_enabled = var.ipv6_enabled
  }

  dynamic "network" {
    for_each = var.network_id != null ? [var.network_id] : []
    content {
      network_id = network.value
      ip         = var.network_ip
    }
  }

  lifecycle {
    # changing either forces a server replacement
    ignore_changes = [ssh_keys, user_data]
  }
}
