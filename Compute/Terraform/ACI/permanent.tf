terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0" # Or your preferred version
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      recover_soft_deleted_key_vaults = true
      purge_soft_delete_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

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


# Azure Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = var.keyvault_name
  location                    = var.keyvault_location
  resource_group_name         = azurerm_resource_group.rg.name
  
  # Key Vault requires tenant_id (pulled dynamically via the data source)
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  soft_delete_retention_days  = 90
  purge_protection_enabled    = false
}


variable "keyvault_name" {
  type        = string
  description = "Globally unique name for the Key Vault (3-24 alphanumeric characters and hyphens)"
  default     = "kvwc2026"
}

variable "keyvault_location" {
  type        = string
  description = "Location from Keyvault"
  default     = "westus"
}

#
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