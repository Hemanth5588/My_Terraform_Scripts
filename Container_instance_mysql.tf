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
variable "container_instance_name" {}
variable "container_OS_type" {}
variable "ip_address_type" {}
variable "container_CPU" {}
variable "container_image" {}
variable "container_memory" {}
variable "container_name" {}
variable "port" {}
variable "protocol" {}
variable "image_registry_server" {}
variable "dockerhub_username" {}
variable "dockerhub_password" {}
variable "mysql_root_password" {}


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

 # Create Azure Container instance
resource "azurerm_container_group" "my_containers" {
  location            = azurerm_resource_group.my_project1.location
  name                = var.container_instance_name
  os_type             = var.container_OS_type
  ip_address_type = var.ip_address_type
  resource_group_name = azurerm_resource_group.my_project1.name
  container {
    cpu    = var.container_CPU
    image  = var.container_image
    memory = var.container_memory
    name   = var.container_name
    environment_variables = {
      MYSQL_ROOT_PASSWORD= var.mysql_root_password
    }
    ports {
      port = var.port
      protocol = var.protocol
    }
  }
   image_registry_credential {
     server   = var.image_registry_server
     username = var.dockerhub_username
     password = var.dockerhub_password
  }
}
