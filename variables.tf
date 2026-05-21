variable "tenancy_ocid" {
  type        = string
  description = "OCID of the OCI tenancy."
}

variable "compartment_ocid" {
  type        = string
  description = "OCID of the compartment to create resources in. Usually your tenancy OCID."
}

variable "region" {
  type        = string
  description = "OCI region identifier (e.g. us-ashburn-1, eu-frankfurt-1). Must be your home region for Always Free eligibility."
}

variable "user_ocid" {
  type        = string
  sensitive   = true
  description = "OCID of the OCI user with API key access."
}

variable "fingerprint" {
  type        = string
  sensitive   = true
  description = "Fingerprint of the OCI API key."
}

variable "private_key" {
  type        = string
  sensitive   = true
  description = "Private key content for the OCI API key."
}

variable "name_prefix" {
  type        = string
  default     = "dw"
  description = "Prefix used for OCI resource display names."
}

variable "ssh_public_key" {
  type        = string
  sensitive   = true
  description = "SSH public key string for accessing the compute instance."
}

variable "availability_domain_index" {
  type        = number
  default     = 0
  description = "Index into the list of availability domains (0 = first AD)."
}

variable "jwt_secret" {
  type        = string
  sensitive   = true
  description = "Secret key used for signing JWT tokens."
}

variable "jwt_expiration" {
  type        = string
  default     = "86400000"
  description = "JWT token expiration in milliseconds (default 24h)."
}

variable "app_admin_username" {
  type        = string
  default     = "admin"
  description = "Username for the default admin user."
}

variable "app_admin_password" {
  type        = string
  sensitive   = true
  description = "Password for the default admin user."
}

variable "app_admin_email" {
  type        = string
  default     = "admin@digitalwallet.com"
  description = "Email for the default admin user."
}

variable "docker_image_tag" {
  type        = string
  default     = "latest"
  description = "Tag for Docker images pulled from the registry."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional free-form tags to apply to resources."
}
