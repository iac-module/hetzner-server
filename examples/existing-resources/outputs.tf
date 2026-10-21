output "ipv4_address" {
  description = "Public IPv4 address of the server."
  value       = module.server.ipv4_address
}

output "server_id" {
  description = "ID of the server."
  value       = module.server.server_id
}
