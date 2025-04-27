resource "azurerm_virtual_network_peering" "az_subscription_1_peerings" {
  for_each = {
    for peering_name, peering in local.peerings :
    peering_name => peering
    if peering.from_subscription_name == lookup(local.subscription_names_by_slot, local._s1, null)
  }

  depends_on = [
    module.az_subscription_1_infra_map,
    module.az_subscription_2_infra_map,
    module.az_subscription_3_infra_map,
    module.az_subscription_4_infra_map,
    module.az_subscription_5_infra_map,
    module.az_subscription_6_infra_map,
    module.az_subscription_7_infra_map,
    module.az_subscription_8_infra_map,
    module.az_subscription_9_infra_map,
    module.az_subscription_10_infra_map
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
    module.az_subscription_2_infra_map,
    module.az_subscription_3_infra_map,
    module.az_subscription_4_infra_map,
    module.az_subscription_5_infra_map,
    module.az_subscription_6_infra_map,
    module.az_subscription_7_infra_map,
    module.az_subscription_8_infra_map,
    module.az_subscription_9_infra_map,
    module.az_subscription_10_infra_map
  ]

  provider                  = azurerm.az_subscription_2
  name                      = each.key
  resource_group_name       = each.value.from_resource_group_name
  virtual_network_name      = each.value.from_virtual_network_name
  remote_virtual_network_id = each.value.to_remote_virtual_network_id
}

resource "azurerm_virtual_network_peering" "az_subscription_3_peerings" {
  for_each = {
    for peering_name, peering in local.peerings :
    peering_name => peering
    if peering.from_subscription_name == lookup(local.subscription_names_by_slot, local._s3, null)
  }

  depends_on = [
    module.az_subscription_1_infra_map,
    module.az_subscription_2_infra_map,
    module.az_subscription_3_infra_map,
    module.az_subscription_4_infra_map,
    module.az_subscription_5_infra_map,
    module.az_subscription_6_infra_map,
    module.az_subscription_7_infra_map,
    module.az_subscription_8_infra_map,
    module.az_subscription_9_infra_map,
    module.az_subscription_10_infra_map
  ]

  provider                  = azurerm.az_subscription_3
  name                      = each.key
  resource_group_name       = each.value.from_resource_group_name
  virtual_network_name      = each.value.from_virtual_network_name
  remote_virtual_network_id = each.value.to_remote_virtual_network_id
}

resource "azurerm_virtual_network_peering" "az_subscription_4_peerings" {
  for_each = {
    for peering_name, peering in local.peerings :
    peering_name => peering
    if peering.from_subscription_name == lookup(local.subscription_names_by_slot, local._s4, null)
  }

  depends_on = [
    module.az_subscription_1_infra_map,
    module.az_subscription_2_infra_map,
    module.az_subscription_3_infra_map,
    module.az_subscription_4_infra_map,
    module.az_subscription_5_infra_map,
    module.az_subscription_6_infra_map,
    module.az_subscription_7_infra_map,
    module.az_subscription_8_infra_map,
    module.az_subscription_9_infra_map,
    module.az_subscription_10_infra_map
  ]

  provider                  = azurerm.az_subscription_4
  name                      = each.key
  resource_group_name       = each.value.from_resource_group_name
  virtual_network_name      = each.value.from_virtual_network_name
  remote_virtual_network_id = each.value.to_remote_virtual_network_id
}

resource "azurerm_virtual_network_peering" "az_subscription_5_peerings" {
  for_each = {
    for peering_name, peering in local.peerings :
    peering_name => peering
    if peering.from_subscription_name == lookup(local.subscription_names_by_slot, local._s5, null)
  }

  depends_on = [
    module.az_subscription_1_infra_map,
    module.az_subscription_2_infra_map,
    module.az_subscription_3_infra_map,
    module.az_subscription_4_infra_map,
    module.az_subscription_5_infra_map,
    module.az_subscription_6_infra_map,
    module.az_subscription_7_infra_map,
    module.az_subscription_8_infra_map,
    module.az_subscription_9_infra_map,
    module.az_subscription_10_infra_map
  ]

  provider                  = azurerm.az_subscription_5
  name                      = each.key
  resource_group_name       = each.value.from_resource_group_name
  virtual_network_name      = each.value.from_virtual_network_name
  remote_virtual_network_id = each.value.to_remote_virtual_network_id
}

resource "azurerm_virtual_network_peering" "az_subscription_6_peerings" {
  for_each = {
    for peering_name, peering in local.peerings :
    peering_name => peering
    if peering.from_subscription_name == lookup(local.subscription_names_by_slot, local._s6, null)
  }

  depends_on = [
    module.az_subscription_1_infra_map,
    module.az_subscription_2_infra_map,
    module.az_subscription_3_infra_map,
    module.az_subscription_4_infra_map,
    module.az_subscription_5_infra_map,
    module.az_subscription_6_infra_map,
    module.az_subscription_7_infra_map,
    module.az_subscription_8_infra_map,
    module.az_subscription_9_infra_map,
    module.az_subscription_10_infra_map
  ]

  provider                  = azurerm.az_subscription_6
  name                      = each.key
  resource_group_name       = each.value.from_resource_group_name
  virtual_network_name      = each.value.from_virtual_network_name
  remote_virtual_network_id = each.value.to_remote_virtual_network_id
}

resource "azurerm_virtual_network_peering" "az_subscription_7_peerings" {
  for_each = {
    for peering_name, peering in local.peerings :
    peering_name => peering
    if peering.from_subscription_name == lookup(local.subscription_names_by_slot, local._s7, null)
  }

  depends_on = [
    module.az_subscription_1_infra_map,
    module.az_subscription_2_infra_map,
    module.az_subscription_3_infra_map,
    module.az_subscription_4_infra_map,
    module.az_subscription_5_infra_map,
    module.az_subscription_6_infra_map,
    module.az_subscription_7_infra_map,
    module.az_subscription_8_infra_map,
    module.az_subscription_9_infra_map,
    module.az_subscription_10_infra_map
  ]

  provider                  = azurerm.az_subscription_7
  name                      = each.key
  resource_group_name       = each.value.from_resource_group_name
  virtual_network_name      = each.value.from_virtual_network_name
  remote_virtual_network_id = each.value.to_remote_virtual_network_id
}

resource "azurerm_virtual_network_peering" "az_subscription_8_peerings" {
  for_each = {
    for peering_name, peering in local.peerings :
    peering_name => peering
    if peering.from_subscription_name == lookup(local.subscription_names_by_slot, local._s8, null)
  }

  depends_on = [
    module.az_subscription_1_infra_map,
    module.az_subscription_2_infra_map,
    module.az_subscription_3_infra_map,
    module.az_subscription_4_infra_map,
    module.az_subscription_5_infra_map,
    module.az_subscription_6_infra_map,
    module.az_subscription_7_infra_map,
    module.az_subscription_8_infra_map,
    module.az_subscription_9_infra_map,
    module.az_subscription_10_infra_map
  ]

  provider                  = azurerm.az_subscription_8
  name                      = each.key
  resource_group_name       = each.value.from_resource_group_name
  virtual_network_name      = each.value.from_virtual_network_name
  remote_virtual_network_id = each.value.to_remote_virtual_network_id
}

resource "azurerm_virtual_network_peering" "az_subscription_9_peerings" {
  for_each = {
    for peering_name, peering in local.peerings :
    peering_name => peering
    if peering.from_subscription_name == lookup(local.subscription_names_by_slot, local._s9, null)
  }

  depends_on = [
    module.az_subscription_1_infra_map,
    module.az_subscription_2_infra_map,
    module.az_subscription_3_infra_map,
    module.az_subscription_4_infra_map,
    module.az_subscription_5_infra_map,
    module.az_subscription_6_infra_map,
    module.az_subscription_7_infra_map,
    module.az_subscription_8_infra_map,
    module.az_subscription_9_infra_map,
    module.az_subscription_10_infra_map
  ]

  provider                  = azurerm.az_subscription_9
  name                      = each.key
  resource_group_name       = each.value.from_resource_group_name
  virtual_network_name      = each.value.from_virtual_network_name
  remote_virtual_network_id = each.value.to_remote_virtual_network_id
}

resource "azurerm_virtual_network_peering" "az_subscription_10_peerings" {
  for_each = {
    for peering_name, peering in local.peerings :
    peering_name => peering
    if peering.from_subscription_name == lookup(local.subscription_names_by_slot, local._s10, null)
  }

  depends_on = [
    module.az_subscription_1_infra_map,
    module.az_subscription_2_infra_map,
    module.az_subscription_3_infra_map,
    module.az_subscription_4_infra_map,
    module.az_subscription_5_infra_map,
    module.az_subscription_6_infra_map,
    module.az_subscription_7_infra_map,
    module.az_subscription_8_infra_map,
    module.az_subscription_9_infra_map,
    module.az_subscription_10_infra_map
  ]

  provider                  = azurerm.az_subscription_10
  name                      = each.key
  resource_group_name       = each.value.from_resource_group_name
  virtual_network_name      = each.value.from_virtual_network_name
  remote_virtual_network_id = each.value.to_remote_virtual_network_id
}



