# token is read from HCLOUD_TOKEN
provider "hcloud" {}

# reuse an ssh key and a firewall that already exist in the project
module "server" {
  source = "../.."

  name        = "web-1"
  server_type = "cax11"
  location    = "fsn1"

  create_ssh_key         = false
  existing_ssh_key_names = [var.ssh_key_name]

  create_firewall        = false
  existing_firewall_name = var.firewall_name
}
