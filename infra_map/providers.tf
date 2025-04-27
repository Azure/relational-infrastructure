provider "azapi" {
}

provider "azurerm" {
  features {}

  alias               = "az_subscription_1"
  storage_use_azuread = true
  subscription_id     = local.subscription_ids[0]
}

provider "azurerm" {
  features {}

  alias               = "az_subscription_2"
  storage_use_azuread = true
  subscription_id     = local.subscription_ids[1]
}

provider "azurerm" {
  features {}

  alias               = "az_subscription_3"
  storage_use_azuread = true
  subscription_id     = local.subscription_ids[2]
}

provider "azurerm" {
  features {}

  alias               = "az_subscription_4"
  storage_use_azuread = true
  subscription_id     = local.subscription_ids[3]
}

provider "azurerm" {
  features {}

  alias               = "az_subscription_5"
  storage_use_azuread = true
  subscription_id     = local.subscription_ids[4]
}

provider "azurerm" {
  features {}

  alias               = "az_subscription_6"
  storage_use_azuread = true
  subscription_id     = local.subscription_ids[5]
}

provider "azurerm" {
  features {}

  alias               = "az_subscription_7"
  storage_use_azuread = true
  subscription_id     = local.subscription_ids[6]
}

provider "azurerm" {
  features {}

  alias               = "az_subscription_8"
  storage_use_azuread = true
  subscription_id     = local.subscription_ids[7]
}

provider "azurerm" {
  features {}

  alias               = "az_subscription_9"
  storage_use_azuread = true
  subscription_id     = local.subscription_ids[8]
}

provider "azurerm" {
  features {}

  alias               = "az_subscription_10"
  storage_use_azuread = true
  subscription_id     = local.subscription_ids[9]
}
