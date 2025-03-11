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
  # subscription_id = "00363a64-55c1-4807-92a4-7dfe011d5222"
}
