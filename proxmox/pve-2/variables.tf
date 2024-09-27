# Variables for Proxmox provider
variable "proxmox_api_url" {
  type        = string
  description = "The URL of the Proxmox API (e.g., https://proxmox.example.com:8006/api2/json)"
}

variable "proxmox_api_token" {
  type        = string
  description = "API token for Proxmox (format: USER@REALM!TOKENID=UUID)"
  sensitive   = true
}

variable "proxmox_ssh_user" {
  type        = string
  description = "SSH username for Proxmox operations that require SSH access"
  default     = "root"
}

# Variables for VM configuration
variable "proxmox_node" {
  type        = string
  description = "The name of the Proxmox node"
  default     = "pve-2"
}

variable "vm_name" {
  type        = string
  description = "The base name of the VM to create"
  default     = "test-ubuntu"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key file"
  default     = "./ssh/terraform_pve2.pub"
}
