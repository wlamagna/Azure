terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

############################
# Configurable inputs
############################
variable "prefix"        { type = string }                     # e.g. "wl-stg"
variable "location"      { type = string  default = "eastus" }
variable "basic_auth_user" { type = string }                   # from .env or TF vars
variable "basic_auth_hash" { type = string }                   # bcrypt hash (not the plain password)
variable "docker_compose_path" { type = string default = "${path.module}/../docker-compose.yml" }

# App Service Plan size (Linux)
variable "sku_name"      { type = string  default = "P1v3" }   # change if you want cheaper tier, e.g. "B1"

############################
# Resource Group
############################
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

############################
# Container Registry
############################
resource "azurerm_container_registry" "acr" {
  name                = replace("${var.prefix}acr", "-", "")
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true  # for sample simplicity; prefer managed identity in prod
}

############################
# App Service Plan (Linux)
############################
resource "azurerm_service_plan" "plan" {
  name                = "${var.prefix}-asp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.sku_name
}

############################
# Linux Web App (Multi-container via Compose)
############################
# We will inject the compose file content into linux_fx_version:
# "COMPOSE|<base64(docker-compose.yml)>"
locals {
  compose_b64 = base64encode(file(var.docker_compose_path))
}

resource "azurerm_linux_web_app" "app" {
  name                = "${var.prefix}-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    linux_fx_version                     = "COMPOSE|${local.compose_b64}"
    always_on                            = true
    app_command_line                     = null
    application_insights_connection_string = null
  }

  https_only = true

  # App settings passed as environment variables to containers
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"

    # Registry credentials (simple sample)
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.acr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.acr.admin_password

    # Basic auth for Caddy (proxy)
    BASIC_AUTH_USER = var.basic_auth_user
    BASIC_AUTH_HASH = var.basic_auth_hash

    # Example: used by compose for image tags
    IMAGE_TAG = "staging"
    ACR_LOGIN_SERVER = azurerm_container_registry.acr.login_server
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      site_config[0].linux_fx_version # prevents spurious diffs caused by Azure reformatting
    ]
  }
}

############################
# Staging Slot
############################
resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.app.id

  site_config {
    linux_fx_version = "COMPOSE|${local.compose_b64}"
    always_on        = true
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.acr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.acr.admin_password

    BASIC_AUTH_USER = var.basic_auth_user
    BASIC_AUTH_HASH = var.basic_auth_hash

    IMAGE_TAG       = "staging"
    ACR_LOGIN_SERVER = azurerm_container_registry.acr.login_server
  }

  https_only = true
}

output "app_url" {
  value = azurerm_linux_web_app.app.default_hostname
}

output "staging_slot_url" {
  value = "${azurerm_linux_web_app_slot.staging.default_hostname}"
}
