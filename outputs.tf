output "server_id" {
  description = "ID of the server."
  value       = hcloud_server.this.id
}

output "server_name" {
  description = "Name of the server."
  value       = hcloud_server.this.name
}

output "ipv4_address" {
  description = "Public IPv4 address of the server."
  value       = hcloud_server.this.ipv4_address
}

output "ipv6_address" {
  description = "Public IPv6 address of the server."
  value       = hcloud_server.this.ipv6_address
}

output "ipv6_network" {
  description = "Public IPv6 /64 network of the server."
  value       = hcloud_server.this.ipv6_network
}

output "ssh_key_ids" {
  description = "IDs of the ssh keys attached to the server (created and existing)."
  value       = local.ssh_key_ids
}

output "created_ssh_key_id" {
  description = "ID of the created ssh key, null when create_ssh_key is false."
  value       = one(hcloud_ssh_key.this[*].id)
}

output "firewall_ids" {
  description = "IDs of the firewalls attached to the server (created and existing)."
  value       = local.firewall_ids
}

output "created_firewall_id" {
  description = "ID of the created firewall, null when create_firewall is false."
  value       = one(hcloud_firewall.this[*].id)
}
