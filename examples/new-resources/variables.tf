variable "ssh_public_key" {
  type        = string
  description = "Public key material, e.g. the content of ~/.ssh/id_ed25519.pub."
}

variable "admin_cidr" {
  type        = string
  description = "CIDR allowed to reach ssh."
  default     = "203.0.113.10/32"
}
