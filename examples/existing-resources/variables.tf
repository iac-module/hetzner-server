variable "ssh_key_name" {
  type        = string
  description = "Name of an existing hcloud ssh key."
  default     = "my-laptop"
}

variable "firewall_name" {
  type        = string
  description = "Name of an existing hcloud firewall."
  default     = "shared"
}
