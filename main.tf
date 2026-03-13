data "azurerm_client_config" "current" {}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.3"
}

module "resource_groups" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.2"
  for_each = local.resource_groups_to_provision

  location = each.value.location
  name     = each.value.name
  lock     = each.value.lock
  tags     = each.value.tags
}
