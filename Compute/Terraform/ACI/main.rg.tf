terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0" # Or your preferred version
    }
  }
}

provider "azurerm" {
  features {}
}


# The resource group where all is in:
resource "azurerm_resource_group" "rg" {
        name = var.resource_group_name
        location = "eastus"
}


# The Cosmos DB Account Resource
resource "azurerm_cosmosdb_account" "free_tier_cosmos" {
  name                = var.cosmosdb_account_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = "West US"
  
  # Standard is the only valid offer type currently
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB" # Defaults to SQL API

  # Maps to --enable-free-tier true
  free_tier_enabled    = true

  # Maps to --default-consistency-level "Session"
  consistency_policy {
    consistency_level = "Session"
  }

  # Maps to --locations regionName="West US"
  geo_location {
    location          = "West US"
    failover_priority = 0
  }
}


# 8. Variables Definitions
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group ($RGNAME)"
  default     = "test01"
}

variable "cosmosdb_account_name" {
  type        = string
  description = "The globally unique name for the Cosmos DB account"
  default     = "test01account"
}
