module "az_subscription_1_infra_map" {
  source = "../subscription_infra_map"

  providers = {
    azurerm = azurerm.az_subscription_1
  }

  deployment_prefix           = var.deployment_prefix
  ddos_protection_plan_name   = var.ddos_protection_plan_name
  default_resource_group_name = local.subscriptions_by_slot[local.az_subscription_1].default_resource_group_name
  enable_automatic_updates    = var.enable_automatic_updates
  enable_full_network_mesh    = var.enable_full_network_mesh
  include_label_tags          = var.include_label_tags
  extensions                  = var.extensions
  virtual_machine_extensions  = var.virtual_machine_extensions
  locations                   = var.locations
  tags                        = var.tags

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
    if var.subscriptions[network.subscription_name].subscription_slot != local.az_subscription_1
  }

  networks = {
    for network_name, network in var.networks
    : network_name => {
      location_name          = network.location_name
      address_space          = network.address_space
      name                   = network.name
      dns_ip_addresses       = network.dns_ip_addresses
      enable_ddos_protection = network.enable_ddos_protection
      subnets                = network.subnets
    }
    if var.subscriptions[network.subscription_name].subscription_slot == local.az_subscription_1
  }

  virtual_machine_sets = {
    for vm_set_name, vm_set in var.virtual_machine_sets
    : vm_set_name => vm_set
    if var.subscriptions[vm_set.subscription_name].subscription_slot == local.az_subscription_1
  }

  virtual_machine_set_specs = {
    for vm_set_name, vm_set_specs in var.virtual_machine_set_specs
    : vm_set_name => vm_set_specs
    if var.subscriptions[var.virtual_machine_sets[vm_set_name].subscription_name].subscription_slot == local.az_subscription_1
  }

  virtual_machine_set_zone_distribution = {
    for vm_set_name, vm_set_zones in var.virtual_machine_set_zone_distribution
    : vm_set_name => vm_set_zones
    if var.subscriptions[var.virtual_machine_sets[vm_set_name].subscription_name].subscription_slot == local.az_subscription_1
  }

  key_vaults = {
    for key_vault_name, key_vault in var.key_vaults
    : key_vault_name => key_vault
    if var.subscriptions[key_vault.subscription_name].subscription_slot == local.az_subscription_1
  }

  private_endpoints = {
    key_vaults = {
      for key_vault_name, key_vault in var.private_endpoints.key_vaults
      : key_vault_name => key_vault
      if var.subscriptions[var.key_vaults[key_vault_name].subscription_name] == local.az_subscription_1
    }
  }
}
