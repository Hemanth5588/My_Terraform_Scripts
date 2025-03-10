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
variable "redis_capacity" {}
variable "redis_family" {}
variable "redis_name" {}
variable "redis_sku" {}

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

# Create Redis cache (in-memory)
resource "azurerm_redis_cache" "intelliqit_redis" {
  capacity            = var.redis_capacity
  family              = var.redis_family
  location            = azurerm_resource_group.my_project1.location
  name                = var.redis_name
  resource_group_name = azurerm_resource_group.my_project1.name
  sku_name            = var.redis_sku
}
