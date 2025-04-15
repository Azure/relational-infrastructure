resource "azurerm_virtual_network_peering" "az_subscription_1_peerings" {
  for_each = {
    for peering_name, peering in local.peerings :
    peering_name => peering
    if peering.from_subscription_name == lookup(local.subscription_names_by_slot, local._s1, null)
  }

  depends_on = [
    module.az_subscription_1_infra_map,
    module.az_subscription_2_infra_map
  ]

  provider                  = azurerm.az_subscription_1
  name                      = each.key
  resource_group_name       = each.value.from_resource_group_name
  virtual_network_name      = each.value.from_virtual_network_name
  remote_virtual_network_id = each.value.to_remote_virtual_network_id
}

resource "azurerm_virtual_network_peering" "az_subscription_2_peerings" {
  for_each = {
    for peering_name, peering in local.peerings :
    peering_name => peering
    if peering.from_subscription_name == lookup(local.subscription_names_by_slot, local._s2, null)
  }

  depends_on = [
    module.az_subscription_1_infra_map,
    module.az_subscription_2_infra_map
  ]

  provider                  = azurerm.az_subscription_2
  name                      = each.key
  resource_group_name       = each.value.from_resource_group_name
  virtual_network_name      = each.value.from_virtual_network_name
  remote_virtual_network_id = each.value.to_remote_virtual_network_id
}



