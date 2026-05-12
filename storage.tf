resource "azurerm_static_web_app" "frontend" {
  name                = local.frontend_static_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = "Global"

  tags = local.common_tags
}
