# token is read from HCLOUD_TOKEN
provider "hcloud" {}

module "server" {
  source = "../.."

  name           = "web-1"
  ssh_public_key = var.ssh_public_key
  labels         = { managed-by = "terraform" }

  # ssh restricted to the admin address
  firewall_rules = [
    { description = "icmp", protocol = "icmp", source_ips = ["0.0.0.0/0", "::/0"] },
    { description = "ssh", protocol = "tcp", port = "22", source_ips = [var.admin_cidr] },
    { description = "http", protocol = "tcp", port = "80", source_ips = ["0.0.0.0/0", "::/0"] },
    { description = "https", protocol = "tcp", port = "443", source_ips = ["0.0.0.0/0", "::/0"] },
  ]
}
