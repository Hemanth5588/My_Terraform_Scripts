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
variable "storage_account_name"{}
variable "account_replication_type"{}
variable "account_tier"{}


# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  client_id = var.client_id
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  client_secret = var.client_secret
}

resource "azurerm_resource_group" "myterraform" {
  location = var.location
  name     = var.resource_group_name
}

# Azure Storage account creation
resource "azurerm_storage_account" "mystorage" {
  name = var.storage_account_name
  location = azurerm_resource_group.myterraform.location
  resource_group_name = azurerm_resource_group.myterraform.name
  account_replication_type = var.account_replication_type
  account_tier = var.account_tier
}
