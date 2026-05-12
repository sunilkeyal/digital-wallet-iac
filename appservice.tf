resource "azurerm_service_plan" "backend" {
  name                = local.app_service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.app_service_plan_sku

  tags = local.common_tags
}

resource "azurerm_linux_web_app" "backend" {
  name                = local.backend_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.backend.id
  https_only          = true

  site_config {
    application_stack {
      java_version        = "25"
      java_server         = "JAVA"
      java_server_version = "25"
    }
  }

  app_settings = {
    WEBSITES_PORT                         = tostring(var.backend_port)
    SPRING_DATA_MONGODB_URI               = azurerm_cosmosdb_account.mongo.primary_mongodb_connection_string
    SPRING_DATA_MONGODB_DATABASE          = local.cosmos_db_name
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.main.connection_string
  }

  tags = local.common_tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "backend" {
  app_service_id = azurerm_linux_web_app.backend.id
  subnet_id      = azurerm_subnet.appservice.id
}
