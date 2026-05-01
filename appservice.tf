resource "azurerm_app_service_plan" "backend" {
  name                = local.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = var.app_service_plan_sku
  }

  tags = {
    environment = "production"
    project     = "digital-wallet"
  }
}

resource "azurerm_app_service" "backend" {
  name                = local.backend_app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.backend.id
  https_only          = true

  site_config {
    linux_fx_version = "JAVA|21-java21"
  }

  app_settings = {
    WEBSITES_PORT                       = tostring(var.backend_port)
    SPRING_DATA_MONGODB_URI             = azurerm_cosmosdb_account.mongo.primary_mongodb_connection_string
    SPRING_DATA_MONGODB_DATABASE        = local.cosmos_db_name
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }

  tags = {
    environment = "production"
    project     = "digital-wallet"
  }
}
