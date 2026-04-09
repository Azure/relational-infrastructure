terraform {
  required_version = ">= 1.9.2"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "2.7"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116, < 5"
    }
  }
}
