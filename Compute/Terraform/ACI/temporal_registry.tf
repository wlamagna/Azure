terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}




# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "West US"
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"

  # Disabled by default; set to true if you need direct admin username/password access
  admin_enabled       = false
}




# Variables matching $RGNAME and $ACREGISTRY
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
  default     = "test01"
}

variable "container_registry_name" {
  type        = string
  description = "Globally unique name for the Azure Container Registry (alphanumeric only)"
  default     = "acrcordoba"
}