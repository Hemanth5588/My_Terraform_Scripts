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
variable "vnet1_cdir" {}
variable "vnet1_name" {}
variable "subnet1_cdir" {}
variable "subnet1_name" {}
variable "subnet2_cdir" {}
variable "subnet2_name" {}



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

# Create Virtual network
resource "azurerm_virtual_network" "vnet1" {
  address_space = [var.vnet1_cdir]
  location            = azurerm_resource_group.my_project1.location
  name                = var.vnet1_name
  resource_group_name = azurerm_resource_group.my_project1.name
}
# Create Subnetwork
 resource "azurerm_subnet" "subnet1" {
   address_prefixes = [var.subnet1_cdir]
   name                 = var.subnet1_name
   resource_group_name  = azurerm_resource_group.my_project1.name
   virtual_network_name = azurerm_virtual_network.vnet1.name
 }
resource "azurerm_subnet" "subnet2" {
  address_prefixes = [var.subnet2_cdir]
  name                 = var.subnet2_name
  resource_group_name  = azurerm_resource_group.my_project1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
}
