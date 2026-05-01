output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "The Azure resource group created for the digital wallet application."
}

output "frontend_static_website_url" {
  value       = azurerm_storage_account.frontend.primary_web_endpoint
  description = "The public URL for the React UI static website."
}

output "backend_app_url" {
  value       = "https://${azurerm_app_service.backend.default_site_hostname}"
  description = "The HTTPS endpoint for the backend App Service."
}

output "cosmos_account_name" {
  value       = azurerm_cosmosdb_account.mongo.name
  description = "Name of the Cosmos DB account used as the backend MongoDB store."
}
