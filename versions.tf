terraform {
  required_version = ">= 1.5.0"

  # To enable remote state storage:
  # 1. Create an Azure Storage Account and container manually:
  #    az group create -n digital-wallet-tfstate -l eastus
  #    az storage account create -n <unique-name> -g digital-wallet-tfstate -l eastus --sku Standard_LRS
  #    az storage container create -n tfstate --account-name <unique-name>
  # 2. Uncomment the backend block below
  # 3. Run: terraform init -migrate
  #
  # backend "azurerm" {
  #   resource_group_name  = "digital-wallet-tfstate"
  #   storage_account_name = "<your-unique-storage-account-name>"
  #   container_name       = "tfstate"
  #   key                  = "digital-wallet.tfstate"
  # }

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
