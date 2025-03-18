 # We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
 terraform {
   required_providers {
     azurerm = {
       source  = "hashicorp/azurerm"
       version = "=4.1.0"
     }
     tls = {
       source  = "hashicorp/tls"
       version = "4.0.6"
     }
     local = {
       source  = "hashicorp/local"
       version = "2.5.2"
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
variable "vnet_cidr" {}
variable "vnet_name" {}
variable "subnet_name" {}
variable "subnet_cidr" {}
variable "public_ip_allocation_method" {}
variable "public_ip_name" {}
#variable "public_ip_sku" {}
variable "nic_name" {}
variable "private_ip_address_allocation" {}
variable "ip_config_name" {}
variable "linux_vm_name" {}
variable "vm_admin_username" {}
variable "vm_size" {}
variable "os_disk_caching" {}
variable "os_disk_storage_account_type" {}
variable "vm_image_offer" {}
variable "vm_image_publisher" {}
variable "vm_image_sku" {}
variable "vm_image_version" {}
variable "nsg_name" {}
variable "security_rule_name" {}
variable "security_rule_priority" {}
variable "security_rule_direction" {}
variable "security_rule_access" {}
variable "security_rule_protocol" {}
variable "security_source_port_range" {}
variable "security_destination_port_range" {}
variable "security_source_address_prefix" {}
variable "security_destination_address_prefix" {}

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

# Create SSH Keys
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Save the private key file at local working dir
resource "local_file" "private_key" {
  filename        = "${path.module}/id_rsa"
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0750"
}

# Save the public key file at local working dir
resource "local_file" "public_key" {
  filename        = "${path.module}/id_rsa.pub"
  content         = tls_private_key.ssh_key.public_key_openssh
  file_permission = "0755"
}

# Create Virtual Network
resource "azurerm_virtual_network" "my_vnet" {
  address_space = [var.vnet_cidr]
  location            = azurerm_resource_group.my_project1.location
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.my_project1.name
}

# Create Subnetwork
resource "azurerm_subnet" "my_subnet1" {
  address_prefixes = [var.subnet_cidr]
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.my_project1.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
}

# Create Public ip
resource "azurerm_public_ip" "my_public_id" {
  allocation_method   = var.public_ip_allocation_method # Can be "Static" or "Dynamic"
# sku = var.public_ip_sku #Note Public IP: "Standard" SKUs require allocation_method to be set to "Static".
  location            = azurerm_resource_group.my_project1.location
  name                = var.public_ip_name
  resource_group_name = azurerm_resource_group.my_project1.name
}

# Create Network Interface card or controller
resource "azurerm_network_interface" "my_nic" {
  location            = azurerm_resource_group.my_project1.location
  name                = var.nic_name
  resource_group_name = azurerm_resource_group.my_project1.name
  # Dynamic means "An IP is automatically assigned during creation of this Network Interface";
  # Static means "User supplied IP address will be used";
  ip_configuration {
    name                          = var.ip_config_name
    private_ip_address_allocation = var.private_ip_address_allocation
    subnet_id = azurerm_subnet.my_subnet1.id
    public_ip_address_id = azurerm_public_ip.my_public_id.id
  }
}

# Create Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "tlabs_host" {
  name                            = var.linux_vm_name
  admin_username                  = var.vm_admin_username
  location                        = azurerm_resource_group.my_project1.location
  network_interface_ids = [azurerm_network_interface.my_nic.id]
  resource_group_name             = azurerm_resource_group.my_project1.name
  size                            = var.vm_size

  admin_ssh_key {
    public_key = tls_private_key.ssh_key.public_key_openssh
    username   = var.vm_admin_username
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    offer     = var.vm_image_offer
    publisher = var.vm_image_publisher
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }
}

 # Create Network Security group
  resource "azurerm_network_security_group" "my_security" {
  location            = azurerm_resource_group.my_project1.location
  name                = var.nsg_name
  resource_group_name = azurerm_resource_group.my_project1.name
  security_rule {
    name = var.security_rule_name
    priority                   = var.security_rule_priority
    direction                  = var.security_rule_direction
    access                     = var.security_rule_access
    protocol                   = var.security_rule_protocol
    source_port_range          = var.security_source_port_range
    destination_port_range     = var.security_destination_port_range
    source_address_prefix      = var.security_source_address_prefix
    destination_address_prefix = var.security_destination_address_prefix
  }
}

# Create Network Interface Security group association
resource "azurerm_network_interface_security_group_association" "my_nisa" {
  network_interface_id      = azurerm_network_interface.my_nic.id
  network_security_group_id = azurerm_network_security_group.my_security.id
}

# Output the public ip
 output "public_ip" {
  value = azurerm_public_ip.my_public_id.ip_address
}
