output "public_ip" {
  value = azurerm_public_ip.fl_poc.ip_address
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.fl_poc.name
}

output "resource_group" {
  value = azurerm_resource_group.fl_poc.name
}

output "ssh_example" {
  value = "ssh -i <your-private-key> ${var.admin_username}@${azurerm_public_ip.fl_poc.ip_address}"
}

output "health_url" {
  value = "http://${azurerm_public_ip.fl_poc.ip_address}:8080/health"
}

output "site_label" {
  value = "azure-${var.azure_location}"
}
