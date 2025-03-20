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
variable "mysql_server_name" {}
variable "admin_user" {}
variable "admin_password" {}
variable "mysql_sku" {}
variable "mysql_version" {}
variable "backup_retention_days" {}
variable "geo_redundant_backup_enabled" {}
variable "private_dns_zone_id" {}
variable "mysql_db_name" {}
variable "mysql_db_charset" {}
variable "mysql_db_collation" {}
variable "mysql_server_firewall_name" {}
variable "start_ip_address" {}
variable "end_ip_address" {}

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

# Create Azure MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "tlabs_mysql_server" {
  location            = azurerm_resource_group.tlabs_project1.location
  name                = var.mysql_server_name
  resource_group_name = azurerm_resource_group.tlabs_project1.name
  administrator_login    = var.admin_user
  administrator_password = var.admin_password
  sku_name               = var.mysql_sku
  version = var.mysql_version
  backup_retention_days = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  private_dns_zone_id = var.private_dns_zone_id
}

# Create Azure MySQL Flexible Database
resource "azurerm_mysql_flexible_database" "tlabs_mysql_db" {
  name                = var.mysql_db_name
  charset             = var.mysql_db_charset
  collation           = var.mysql_db_collation
  resource_group_name = azurerm_resource_group.tlabs_project1.name
  server_name         = azurerm_mysql_flexible_server.tlabs_mysql_server.name
}

# Create Azure MySQL Flexible Server Firewall (Optional)
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_all" {
  name                = var.mysql_server_firewall_name
  resource_group_name = azurerm_resource_group.tlabs_project1.name
  server_name         = azurerm_mysql_flexible_server.tlabs_mysql_server.name
  start_ip_address    = var.start_ip_address
  end_ip_address      = var.end_ip_address
}
