terraform {
  required_version = ">= 1.9.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116, < 5"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "442e93e4-5c85-4e06-91d6-5909a3d6314f"
}
