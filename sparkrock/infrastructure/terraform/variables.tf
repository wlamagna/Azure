variable "prefix" {}
variable "location" { default = "eastus" }
variable "basic_auth_user" {}
variable "basic_auth_hash" {}
variable "docker_compose_path" { default = "${path.module}/../docker-compose.yml" }
variable "sku_name" { default = "P1v3" }
