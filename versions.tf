terraform {
  required_version = ">= 1.5.0"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "placeholder"
    workspaces {
      name = "placeholder"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
