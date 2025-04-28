locals {
  _s6 = "az_subscription_6"
}

module "az_subscription_6_infra_map" {
  source = "../subscription_infra_map"
  count  = local.deploy_to_subscription[local._s6]

  providers = {
    azurerm = azurerm.az_subscription_6
  }

  deployment_prefix          = var.deployment_prefix
  enable_automatic_updates   = var.enable_automatic_updates
  include_label_tags         = var.include_label_tags
  extensions                 = var.extensions
  maintenance_schedules      = var.maintenance_schedules
  virtual_machine_extensions = var.virtual_machine_extensions
  virtual_machine_images     = var.virtual_machine_images
  locations                  = var.locations
  lock_groups                = var.lock_groups

  tags = merge(
    var.tags,
    var.include_label_tags ? {
      "subscription_label" = local.subscription_names_by_slot[local._s6]
    } : {}
  )

  default_resource_group_name      = local.subscriptions_by_slot[local._s6].default_resource_group_name
  private_link_resource_group_name = local.subscriptions_by_slot[local._s6].private_link_resource_group_name

  external_networks = {
    for network_name, network in merge(var.networks, var.external_networks)
    : network_name => {
      address_space = network.address_space

      subnets = {
        for subnet_name, subnet in network.subnets
        : subnet_name => {
          address_space = subnet.address_space
        }
      }
    }
  }

  networks = {
    for network_name, network in var.networks
    : network_name => {
      location_name          = network.location_name
      resource_group_name    = network.resource_group_name
      address_space          = network.address_space
      name                   = network.name
      dns_ip_addresses       = network.dns_ip_addresses
      enable_ddos_protection = network.enable_ddos_protection
      subnets                = network.subnets
      lock_groups            = network.lock_groups
    }
    if local.subscription_slots[network.subscription_name] == local._s6
  }

  resource_groups = {
    for group_name, group in var.resource_groups
    : group_name => group
    if local.subscription_slots[group.subscription_name] == local._s6
  }

  storage_accounts = {
    for account_name, account in var.storage_accounts
    : account_name => account
    if local.subscription_slots[account.subscription_name] == local._s6
  }

  blob_containers = {
    for container_name, container in var.blob_containers
    : container_name => container
    if local.subscription_slots[var.storage_accounts[container.storage_account_name].subscription_name] == local._s6
  }

  file_shares = {
    for share_name, share in var.file_shares
    : share_name => share
    if local.subscription_slots[var.storage_accounts[share.storage_account_name].subscription_name] == local._s6
  }

  virtual_machine_sets = {
    for vm_set_name, vm_set in var.virtual_machine_sets
    : vm_set_name => vm_set
    if local.subscription_slots[vm_set.subscription_name] == local._s6
  }

  virtual_machine_set_specs = {
    for vm_set_name, vm_set_specs in var.virtual_machine_set_specs
    : vm_set_name => vm_set_specs
    if local.subscription_slots[var.virtual_machine_sets[vm_set_name].subscription_name] == local._s6
  }

  virtual_machine_set_zone_distribution = {
    for vm_set_name, vm_set_zones in var.virtual_machine_set_zone_distribution
    : vm_set_name => vm_set_zones
    if local.subscription_slots[var.virtual_machine_sets[vm_set_name].subscription_name] == local._s6
  }

  key_vaults = {
    for key_vault_name, key_vault in var.key_vaults
    : key_vault_name => key_vault
    if local.subscription_slots[key_vault.subscription_name] == local._s6
  }

  private_endpoints = {
    key_vaults = {
      for key_vault_name, key_vault in var.private_endpoints.key_vaults
      : key_vault_name => key_vault
      if local.subscription_slots[var.key_vaults[key_vault_name].subscription_name] == local._s6
    }

    blob_containers = {
      for container_name, container in var.private_endpoints.blob_containers
      : container_name => container
      if local.subscription_slots[var.storage_accounts[var.blob_containers[container_name].storage_account_name].subscription_name] == local._s6
    }

    file_shares = {
      for share_name, share in var.private_endpoints.file_shares
      : share_name => share
      if local.subscription_slots[var.storage_accounts[var.file_shares[share_name].storage_account_name].subscription_name] == local._s6
    }
  }
}

resource "azurerm_virtual_network_peering" "az_subscription_6_peerings" {
  for_each = {
    for pair in flatten([
      for from_name, from_network in var.networks : [
        for to_name in from_network.peered_to : {
          key                    = "peer-${from_name}-to-${to_name}"
          from_name              = from_name
          to_name                = to_name
          from_subscription_name = from_network.subscription_name
        }
        if from_network.subscription_name == try(local.subscription_names_by_slot[local._s6], null)
      ]
    ]) : pair.key => pair
  }

  provider             = azurerm.az_subscription_6
  name                 = each.key
  resource_group_name  = try(module.az_subscription_6_infra_map[0].resource_groups[var.networks[each.value.from_name].resource_group_name].resource_name, null)
  virtual_network_name = try(module.az_subscription_6_infra_map[0].networks[each.value.from_name].resource_name, null)
  
  remote_virtual_network_id = try(
    var.external_networks[each.value.to_name].resource_id,
    module.az_subscription_1_infra_map[0].networks[each.value.to_name].resource_id,
    module.az_subscription_2_infra_map[0].networks[each.value.to_name].resource_id,
    module.az_subscription_3_infra_map[0].networks[each.value.to_name].resource_id,
    module.az_subscription_4_infra_map[0].networks[each.value.to_name].resource_id,
    module.az_subscription_5_infra_map[0].networks[each.value.to_name].resource_id,
    module.az_subscription_6_infra_map[0].networks[each.value.to_name].resource_id,
    module.az_subscription_7_infra_map[0].networks[each.value.to_name].resource_id,
    module.az_subscription_8_infra_map[0].networks[each.value.to_name].resource_id,
    module.az_subscription_9_infra_map[0].networks[each.value.to_name].resource_id,
    module.az_subscription_10_infra_map[0].networks[each.value.to_name].resource_id,
    null
  )

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
}
