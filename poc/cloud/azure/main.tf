terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "fl_poc" {
  name     = "${var.name_prefix}-rg"
  location = var.azure_location
  tags = {
    Project = "fedora-lane-poc"
    Cloud   = "azure"
  }
}

resource "azurerm_virtual_network" "fl_poc" {
  name                = "${var.name_prefix}-vnet"
  address_space       = ["10.40.0.0/16"]
  location            = azurerm_resource_group.fl_poc.location
  resource_group_name = azurerm_resource_group.fl_poc.name
}

resource "azurerm_subnet" "fl_poc" {
  name                 = "${var.name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.fl_poc.name
  virtual_network_name = azurerm_virtual_network.fl_poc.name
  address_prefixes     = ["10.40.1.0/24"]
}

resource "azurerm_public_ip" "fl_poc" {
  name                = "${var.name_prefix}-pip"
  location            = azurerm_resource_group.fl_poc.location
  resource_group_name = azurerm_resource_group.fl_poc.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "fl_poc" {
  name                = "${var.name_prefix}-nsg"
  location            = azurerm_resource_group.fl_poc.location
  resource_group_name = azurerm_resource_group.fl_poc.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "InventorySync"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = var.ssh_cidr
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "fl_poc" {
  name                = "${var.name_prefix}-nic"
  location            = azurerm_resource_group.fl_poc.location
  resource_group_name = azurerm_resource_group.fl_poc.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.fl_poc.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.fl_poc.id
  }
}

resource "azurerm_network_interface_security_group_association" "fl_poc" {
  network_interface_id      = azurerm_network_interface.fl_poc.id
  network_security_group_id = azurerm_network_security_group.fl_poc.id
}

resource "azurerm_linux_virtual_machine" "fl_poc" {
  name                = "${var.name_prefix}-azure-analytics"
  resource_group_name = azurerm_resource_group.fl_poc.name
  location            = azurerm_resource_group.fl_poc.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.fl_poc.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  custom_data = base64encode(file("${path.module}/../cloud-init/fl-rhel-baseline.yaml"))

  tags = {
    Project = "fedora-lane-poc"
    Site    = "azure-${var.azure_location}"
    Role    = "cloud_app"
  }
}
