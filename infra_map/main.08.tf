locals {
  _s8 = "az_subscription_8"
}

module "az_subscription_8_infra_map" {
  source = "../subscription_infra_map"
  count  = local.deploy_to_subscription[local._s8]

  providers = {
    azurerm = azurerm.az_subscription_8
  }

  deployment_prefix          = var.deployment_prefix
  enable_automatic_updates   = var.enable_automatic_updates
  include_label_tags         = var.include_label_tags
  extensions                 = var.extensions
  maintenance_schedules      = var.maintenance_schedules
  virtual_machine_extensions = var.virtual_machine_extensions
  locations                  = var.locations
  lock_groups                = var.lock_groups

  tags = merge(
    var.tags,
    var.include_label_tags ? {
      "subscription_label" = local.subscription_names_by_slot[local._s8]
    } : {}
  )

  default_resource_group_name      = local.subscriptions_by_slot[local._s8].default_resource_group_name
  private_link_resource_group_name = local.subscriptions_by_slot[local._s8].private_link_resource_group_name

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
    if local.subscription_slots[network.subscription_name] == local._s8
  }

  resource_groups = {
    for group_name, group in var.resource_groups
    : group_name => group
    if local.subscription_slots[group.subscription_name] == local._s8
  }

  storage_accounts = {
    for account_name, account in var.storage_accounts
    : account_name => account
    if local.subscription_slots[account.subscription_name] == local._s8
  }

  blob_containers = {
    for container_name, container in var.blob_containers
    : container_name => container
    if local.subscription_slots[var.storage_accounts[container.storage_account_name].subscription_name] == local._s8
  }

  file_shares = {
    for share_name, share in var.file_shares
    : share_name => share
    if local.subscription_slots[var.storage_accounts[share.storage_account_name].subscription_name] == local._s8
  }

  virtual_machine_sets = {
    for vm_set_name, vm_set in var.virtual_machine_sets
    : vm_set_name => vm_set
    if local.subscription_slots[vm_set.subscription_name] == local._s8
  }

  virtual_machine_set_specs = {
    for vm_set_name, vm_set_specs in var.virtual_machine_set_specs
    : vm_set_name => vm_set_specs
    if local.subscription_slots[var.virtual_machine_sets[vm_set_name].subscription_name] == local._s8
  }

  virtual_machine_set_zone_distribution = {
    for vm_set_name, vm_set_zones in var.virtual_machine_set_zone_distribution
    : vm_set_name => vm_set_zones
    if local.subscription_slots[var.virtual_machine_sets[vm_set_name].subscription_name] == local._s8
  }

  key_vaults = {
    for key_vault_name, key_vault in var.key_vaults
    : key_vault_name => key_vault
    if local.subscription_slots[key_vault.subscription_name] == local._s8
  }

  private_endpoints = {
    key_vaults = {
      for key_vault_name, key_vault in var.private_endpoints.key_vaults
      : key_vault_name => key_vault
      if local.subscription_slots[var.key_vaults[key_vault_name].subscription_name] == local._s8
    }

    blob_containers = {
      for container_name, container in var.private_endpoints.blob_containers
      : container_name => container
      if vlocal.subscription_slots[var.storage_accounts[var.blob_containers[container_name].storage_account_name].subscription_name] == local._s8
    }

    file_shares = {
      for share_name, share in var.private_endpoints.file_shares
      : share_name => share
      if local.subscription_slots[var.storage_accounts[var.file_shares[share_name].storage_account_name].subscription_name] == local._s8
    }
  }
}
