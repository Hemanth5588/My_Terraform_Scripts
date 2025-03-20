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
variable "cluster_name" {}
variable "cluster_dns_prefix" {}
variable "node_pool_name" {}
variable "node_size" {}
variable "node_count" {}
variable "identity" {}


# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  client_id = var.client_id
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  client_secret = var.client_secret
}

 # Create Azure Resource group
resource "azurerm_resource_group" "tlabs_project1" {
  location = var.location
  name     = var.resource_group_name
}

# Create Azure AKS Cluster
resource "azurerm_kubernetes_cluster" "tlabs_cluster" {
  location            = azurerm_resource_group.tlabs_project1.location
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.tlabs_project1.name
  dns_prefix = var.cluster_dns_prefix
  default_node_pool {
    name    = var.node_pool_name
    vm_size = var.node_size
    node_count = var.node_count
  }
  identity {
    type = var.identity
  }
}
