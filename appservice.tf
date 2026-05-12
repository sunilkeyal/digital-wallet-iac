resource "azurerm_service_plan" "backend" {
  name                = local.app_service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"

  tags = local.common_tags
}

resource "azurerm_linux_web_app" "backend" {
  name                = local.backend_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.backend.id
  https_only          = true

  site_config {
    always_on = false

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
    JWT_SECRET                            = var.jwt_secret
    JWT_EXPIRATION                        = "86400000"
    APP_ADMIN_USERNAME                    = "admin"
    APP_ADMIN_PASSWORD                    = var.app_admin_password
    APP_ADMIN_EMAIL                       = "admin@digitalwallet.com"
  }

  tags = local.common_tags
}
