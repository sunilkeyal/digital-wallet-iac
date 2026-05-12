output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "The Azure resource group created for the digital wallet application."
}

output "frontend_static_website_url" {
  value       = azurerm_storage_account.frontend.primary_web_endpoint
  description = "The public URL for the React UI static website."
}

output "backend_app_url" {
  value       = "https://${azurerm_linux_web_app.backend.default_hostname}"
  description = "The HTTPS endpoint for the backend App Service."
}

output "cosmos_account_name" {
  value       = azurerm_cosmosdb_account.mongo.name
  description = "Name of the Cosmos DB account used as the backend MongoDB store."
}

output "application_insights_connection_string" {
  value       = azurerm_application_insights.main.connection_string
  description = "Connection string for Application Insights."
  sensitive   = true
}

output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.main.workspace_id
  description = "The workspace ID of the Log Analytics workspace."
}

output "vnet_id" {
  value       = azurerm_virtual_network.main.id
  description = "ID of the created virtual network."
}
