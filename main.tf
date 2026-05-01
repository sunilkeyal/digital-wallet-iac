locals {
  resource_prefix               = lower(var.resource_prefix)
  name_suffix                   = random_string.name_suffix.result
  backend_app_name              = "${local.resource_prefix}-backend-${local.name_suffix}"
  frontend_storage_account_name = substr("${local.resource_prefix}front${local.name_suffix}", 0, 24)
  cosmos_account_name           = substr("${local.resource_prefix}cosmos${local.name_suffix}", 0, 50)
  app_service_plan_name         = "${local.backend_app_name}-plan"
  cosmos_db_name                = "digital-wallet"
}

resource "random_string" "name_suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
