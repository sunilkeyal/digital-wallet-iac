variable "arm_subscription_id" {
  type        = string
  description = "Azure Subscription ID."
}

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

variable "backend_port" {
  type        = number
  default     = 8080
  description = "Port that the backend Spring Boot application listens on."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to all resources."
}

variable "jwt_secret" {
  type        = string
  sensitive   = true
  description = "Secret key used for signing JWT tokens."
}

variable "app_admin_password" {
  type        = string
  sensitive   = true
  description = "Password for the default admin user."
}
