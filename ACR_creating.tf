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
variable "container_registry_name"{}
variable "container_registry_sku"{}
variable "admin_previlages"{}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  client_id = var.client_id
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  client_secret = var.client_secret
}

# Azure Resource Group creation
resource "azurerm_resource_group" "myterraform" {
  location = var.location
  name     = var.resource_group_name
}

# Azure Container Registry creation
resource "azurerm_container_registry" "myacr" {
  location            = azurerm_resource_group.myterraform.location
  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.myterraform.name
  sku                 = var.container_registry_sku
  admin_enabled = var.admin_previlages
}
