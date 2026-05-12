provider "azurerm" {
  features {}
  use_cli  = false
  use_oidc = true
}

provider "random" {
}
