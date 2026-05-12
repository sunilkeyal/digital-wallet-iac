variable "resource_prefix" {
  type        = string
  default     = "digitalwallet"
  description = "Prefix used for Azure resource names. Will be normalized to lowercase letters and digits."
}

variable "resource_group_name" {
  type        = string
  default     = "digital-wallet-rg"
  description = "Name of the Azure resource group to create."
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region where resources will be created."
}

variable "app_service_plan_sku" {
  type        = string
  default     = "S1"
  description = "SKU size for the Azure App Service plan. Requires S1 or higher for VNet integration."

  validation {
    condition     = can(regex("^[BPSF]\\d{1,2}(v\\d)?$", var.app_service_plan_sku))
    error_message = "Must be a valid App Service plan SKU (e.g. B1, S1, S2, P1v2, F1)."
  }
}

variable "frontend_index_document" {
  type        = string
  default     = "index.html"
  description = "Static website index document."
}

variable "frontend_error_document" {
  type        = string
  default     = "index.html"
  description = "Static website error document, used for client-side routing."
}

variable "backend_port" {
  type        = number
  default     = 8080
  description = "Port that the backend Spring Boot application listens on."
}

variable "vnet_address_space" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Address space for the virtual network."
}

variable "subnet_private_endpoints_prefix" {
  type        = string
  default     = "10.0.1.0/24"
  description = "Address prefix for the private endpoints subnet."
}

variable "subnet_appservice_prefix" {
  type        = string
  default     = "10.0.2.0/24"
  description = "Address prefix for the App Service delegated subnet."
}

variable "log_analytics_sku" {
  type        = string
  default     = "PerGB2018"
  description = "SKU for the Log Analytics workspace."

  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.log_analytics_sku)
    error_message = "Must be a valid Log Analytics SKU (e.g. PerGB2018, Free, Standalone)."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to all resources."
}
