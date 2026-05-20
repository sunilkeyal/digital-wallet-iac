locals {
  name_prefix   = var.name_prefix
  name_suffix   = random_string.name_suffix.result
  display_name  = "${local.name_prefix}-${local.name_suffix}"
  vcn_cidr      = "10.0.0.0/16"
  public_cidr   = "10.0.1.0/24"

  common_tags = merge(
    {
      environment = "development"
      project     = "digital-wallet"
      managed-by  = "terraform"
    },
    var.tags
  )
}

resource "random_string" "name_suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}
