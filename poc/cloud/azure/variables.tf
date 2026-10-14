variable "azure_location" {
  type        = string
  description = "Azure region (Fedora Lane secondary / EMEA-style)"
  default     = "westeurope"
}

variable "name_prefix" {
  type    = string
  default = "fl-poc"
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "admin_username" {
  type    = string
  default = "fladmin"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to your SSH public key file"
}

variable "ssh_cidr" {
  type        = string
  description = "Your public IP as x.x.x.x/32"
}

# Default: RHEL 9 PAYG — accept Marketplace terms in Azure if prompted.
# For practice without RHEL: publisher=resf, offer=rockylinux-x86_64, sku=9-base
variable "image_publisher" {
  type    = string
  default = "RedHat"
}

variable "image_offer" {
  type    = string
  default = "RHEL"
}

variable "image_sku" {
  type    = string
  default = "9_4"
}

variable "image_version" {
  type    = string
  default = "latest"
}
