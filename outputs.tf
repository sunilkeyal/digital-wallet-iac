output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "The Azure resource group created for the digital wallet application."
}

output "frontend_static_app_name" {
  value       = azurerm_static_web_app.frontend.name
  description = "Name of the Azure Static Web App (used for deployment)."
}

output "frontend_static_website_url" {
  value       = "https://${azurerm_static_web_app.frontend.default_host_name}"
  description = "The public URL for the React UI served by Azure Static Web Apps."
}

output "backend_app_name" {
  value       = azurerm_linux_web_app.backend.name
  description = "Name of the backend App Service (used for deployment)."
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
