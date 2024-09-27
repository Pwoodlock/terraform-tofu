# Provider configuration
provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = var.proxmox_api_token
  insecure  = true # Only use this for testing with self-signed certificates
  ssh {
    agent    = true
    username = var.proxmox_ssh_user
  }
}

# Cloud-init configuration
data "template_file" "user_data" {
  template = file("${path.module}/cloud-init.yaml")
  vars = {
    ssh_public_key = file(var.ssh_public_key_path)
  }
}

# VM configuration
resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  count     = 1
  name      = "${var.vm_name}-${count.index + 1}"
  node_name = var.proxmox_node

  operating_system {
    type = "l26"
  }

  machine = "q35"

  agent {
    enabled = true
  }

  cpu {
    cores = 4
    type  = "host"
    units = 1024
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
    ssd          = true
  }

  initialization {
    datastore_id = "local-lvm"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      keys = [trimspace(file(var.ssh_public_key_path))]
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_user_data.id
  }

  network_device {
    bridge = "vmbr3"
  }

  vga {
    type = "std"
  }

  serial_device {}
}

# Cloud-init user data file in Proxmox
resource "proxmox_virtual_environment_file" "cloud_init_user_data" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
    data = data.template_file.user_data.rendered
    file_name = "cloud-init-user-data.yaml"
  }
}

# Ubuntu cloud image
resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_node
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"

    lifecycle {
    prevent_destroy = true
  }
}

# Output
output "vm_ipv4_addresses" {
  value = proxmox_virtual_environment_vm.ubuntu_vm[*].ipv4_addresses
}