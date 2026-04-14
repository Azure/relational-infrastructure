terraform {
  required_version = ">= 1.9.2"
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
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
