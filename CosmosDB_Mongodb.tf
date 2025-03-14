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
variable "cosmos_account_name" {}
variable "offer_type" {}
variable "db_type" {}
variable "failover_priority" {}
variable "consistency_level" {}
variable "max_interval" {}
variable "max_staleness" {}


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

# Create Azure Cosmos DB
resource "azurerm_cosmosdb_account" "my_cosmosdb" {
  location            = azurerm_resource_group.my_project1.location
  name                = var.cosmos_account_name
  offer_type          = var.offer_type
  resource_group_name = azurerm_resource_group.my_project1.name
  kind = var.db_type

consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.max_interval
    max_staleness_prefix    = var.max_staleness
  }
geo_location {
  failover_priority = var.failover_priority
  location          = azurerm_resource_group.my_project1.location
  }
}

