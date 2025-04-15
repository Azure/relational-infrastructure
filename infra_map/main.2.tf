locals {
  _s2 = "az_subscription_2"
}

module "az_subscription_2_infra_map" {
  source = "../subscription_infra_map"
  count  = try(local.subscriptions_by_slot[local._s2] != null ? 1 : 0, 0)

  providers = {
    azurerm = azurerm.az_subscription_2
  }

  deployment_prefix          = var.deployment_prefix
  enable_automatic_updates   = var.enable_automatic_updates
  include_label_tags         = var.include_label_tags
  extensions                 = var.extensions
  virtual_machine_extensions = var.virtual_machine_extensions
  locations                  = var.locations
  lock_groups                = var.lock_groups

  tags = merge(
    var.tags,
    var.include_label_tags ? {
      "subscription_label" = local.subscription_names_by_slot[local._s2]
    } : {}
  )

  default_resource_group_name      = local.subscriptions_by_slot[local._s2].default_resource_group_name
  private_link_resource_group_name = local.subscriptions_by_slot[local._s2].private_link_resource_group_name

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
    if var.subscriptions[network.subscription_name].subscription_slot == local._s2
  }

  resource_groups = {
    for group_name, group in var.resource_groups
    : group_name => group
    if var.subscriptions[group.subscription_name].subscription_slot == local._s2
  }

  virtual_machine_sets = {
    for vm_set_name, vm_set in var.virtual_machine_sets
    : vm_set_name => vm_set
    if var.subscriptions[vm_set.subscription_name].subscription_slot == local._s2
  }

  virtual_machine_set_specs = {
    for vm_set_name, vm_set_specs in var.virtual_machine_set_specs
    : vm_set_name => vm_set_specs
    if var.subscriptions[var.virtual_machine_sets[vm_set_name].subscription_name].subscription_slot == local._s2
  }

  virtual_machine_set_zone_distribution = {
    for vm_set_name, vm_set_zones in var.virtual_machine_set_zone_distribution
    : vm_set_name => vm_set_zones
    if var.subscriptions[var.virtual_machine_sets[vm_set_name].subscription_name].subscription_slot == local._s2
  }

  key_vaults = {
    for key_vault_name, key_vault in var.key_vaults
    : key_vault_name => key_vault
    if var.subscriptions[key_vault.subscription_name].subscription_slot == local._s2
  }

  private_endpoints = {
    key_vaults = {
      for key_vault_name, key_vault in var.private_endpoints.key_vaults
      : key_vault_name => key_vault
      if var.subscriptions[var.key_vaults[key_vault_name].subscription_name] == local._s2
    }
  }
}
