resource "azurerm_static_web_app" "frontend" {
  name                = local.frontend_static_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = "eastus2"

  tags = local.common_tags
}
