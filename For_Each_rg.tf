 # We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.21.1"
    }
  }
}

#Variable defining
variable "client_id" {}
variable "tenant_id" {}
variable "client_secret" {}
variable "subscription_id" {}
variable "location" {}
variable "resource_groups" {
  default = {
    dev = "East US"
    prod = "West Europe"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  client_id = var.client_id
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  client_secret = var.client_secret
}

 # Create Azure Resource group
resource "azurerm_resource_group" "commerce_rg" {
  for_each = var.resource_groups
  name = "${each.key}-rg"
  location = each.value
}
