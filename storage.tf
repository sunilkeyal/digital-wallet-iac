resource "azurerm_storage_account" "frontend" {
  name                       = local.frontend_storage_account_name
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  account_tier               = "Standard"
  account_replication_type   = "LRS"
  https_traffic_only_enabled = true

  static_website {
    index_document     = var.frontend_index_document
    error_404_document = var.frontend_error_document
  }

  tags = {
    environment = "production"
    project     = "digital-wallet"
  }
}
