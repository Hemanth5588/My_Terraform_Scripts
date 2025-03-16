 # We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

#Variable defining
variable "client_id" {}
variable "tenant_id" {}
variable "client_secret" {}
variable "subscription_id" {}
variable "location" {}
variable "resource_group_name" {}


# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  client_id = var.client_id
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  client_secret = var.client_secret
}

 # Create Azure Resource group
resource "azurerm_resource_group" "my_project1" {
  location = var.location
  name     = var.resource_group_name
}

# Create Virtual Network
resource "azurerm_virtual_network" "my_vnet" {
  address_space = ["10.0.0.0/24"]
  location            = azurerm_resource_group.my_project1.location
  name                = "myvent"
  resource_group_name = azurerm_resource_group.my_project1.name
}

# Create Subnetwork
resource "azurerm_subnet" "my_subnet1" {
  address_prefixes = ["10.0.0.0/25"]
  name                 = "mysubnet1"
  resource_group_name  = azurerm_resource_group.my_project1.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
}

# Create Public Ip Address
resource "azurerm_public_ip" "my_public_ip" {
  allocation_method   = "Static"
  sku = "Standard"
  location            = azurerm_resource_group.my_project1.location
  name                = "my-public-ip-${count.index}"
  resource_group_name = azurerm_resource_group.my_project1.name
  count = 2
}

# Create Network Interface with Public IP
resource "azurerm_network_interface" "my_nic" {
  location            = azurerm_resource_group.my_project1.location
  name                = "intelliqnic-${count.index}"
  resource_group_name = azurerm_resource_group.my_project1.name
  count = 2
  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.my_subnet1.id
    public_ip_address_id = azurerm_public_ip.my_public_ip[count.index].id
  }
}

# Create Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "my_host" {
  admin_username                  = "myadmin"
  admin_password                  = "intelliqi1@123"
  disable_password_authentication = false
  location                        = azurerm_resource_group.my_project1.location
  name                            = "Azurehost-${count.index}"
  network_interface_ids = [azurerm_network_interface.my_nic[count.index].id]
  resource_group_name             = azurerm_resource_group.my_project1.name
  size                            = "Standard_B1s"
  count = 2

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    offer     = "UbuntuServer"
    publisher = "Canonical"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

 # Create Network Security group
  resource "azurerm_network_security_group" "my_security" {
  location            = azurerm_resource_group.my_project1.location
  name                = "intelliqsecurity"
  resource_group_name = azurerm_resource_group.my_project1.name
  security_rule {
    name = "intelliqrule"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create Network Interface Security group association
resource "azurerm_network_interface_security_group_association" "my_nisa" {
  count = 2
  network_interface_id      = azurerm_network_interface.my_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.my_security.id
}
