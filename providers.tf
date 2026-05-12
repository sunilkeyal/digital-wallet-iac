provider "azurerm" {
  features {}
  use_cli         = false
  use_oidc        = true
  subscription_id = var.arm_subscription_id
}

provider "random" {
}
