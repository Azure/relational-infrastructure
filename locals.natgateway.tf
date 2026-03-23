locals {
  # =============================================================================
  # NAT Gateway Names
  # =============================================================================
  nat_gateway_names = {
    for nat_key, nat in var.nat_gateways
    : nat_key => (
      replace(
        nat.name == null
        ? "${var.deployment_prefix}-${nat_key}-natgw"
        : "${var.deployment_prefix}-${nat.name}",
        "_", "-"
      )
    )
  }

  # =============================================================================
  # NAT Gateway Tags
  # =============================================================================
  nat_gateway_tags = {
    for nat_key, nat in var.nat_gateways :
    nat_key => merge(
      var.tags,
      nat.tags,
      var.include_label_tags ? {
        "nat_gateway_label" = nat_key,
        "location_label"    = nat.location_key_reference,
        "resource_group_label" = nat.resource_group_key_reference
      } : {}
    )
  }

  # =============================================================================
  # NAT Gateway Locks
  # =============================================================================
  nat_gateway_locked = {
    for nat_key, nat in var.nat_gateways :
    nat_key => (
      (length(nat.lock_groups_key_reference) > 0) &&
      (length([
        for group in nat.lock_groups_key_reference :
        group if !contains(keys(local.unlocked_groups), group)
      ]) > 0)
    )
  }

  nat_gateway_locks = {
    for nat_key, nat in var.nat_gateways :
    nat_key => (
      length([
        for group in nat.lock_groups_key_reference :
        group if contains(keys(local.locked_groups), group)
      ]) > 0
      ? (
        anytrue([
          for group in nat.lock_groups_key_reference :
          contains(keys(local.locked_groups), group) && try(local.locked_groups[group].read_only, false)
        ])
        ? { kind = local.lock_modes.read_only, name = "${local.nat_gateway_names[nat_key]}-lock" }
        : { kind = local.lock_modes.no_delete, name = "${local.nat_gateway_names[nat_key]}-lock" }
      )
      : null
    )
  }

  # =============================================================================
  # NAT Gateway Public IP Configurations
  # Groups public IPs by NAT Gateway and builds configuration for the AVM module
  # =============================================================================

  # Build public_ips map for each NAT Gateway (defines which public IPs to create)
  nat_gateway_public_ips = {
    for nat_key, nat in var.nat_gateways :
    nat_key => {
      for pip_key, pip in nat.public_ips :
      pip_key => {
        name = coalesce(pip.name, "${local.nat_gateway_names[nat_key]}-${pip_key}-pip")
      }
    }
  }

  # Build public_ip_configuration for each NAT Gateway (shared config for all public IPs)
  # The AVM module uses public_ip_configuration as shared settings for public IPs created via public_ips
  # Note: DDoS protection is not set for NAT Gateway public IPs (validated in variables)
  nat_gateway_public_ip_config = {
    for nat_key, nat in var.nat_gateways :
    nat_key => {
      for pip_key, pip in nat.public_ips :
      pip_key => {
        allocation_method       = var.public_ip_configurations[pip.public_ip_key_reference].allocation_method
        ddos_protection_mode    = "VirtualNetworkInherited" # NAT Gateway does not support DDoS protection
        ddos_protection_plan_id = null                       # NAT Gateway does not support DDoS protection plan
        domain_name_label       = var.public_ip_configurations[pip.public_ip_key_reference].domain_name_label
        idle_timeout_in_minutes = var.public_ip_configurations[pip.public_ip_key_reference].idle_timeout_in_minutes
        ip_version              = var.public_ip_configurations[pip.public_ip_key_reference].ip_version
        sku                     = var.public_ip_configurations[pip.public_ip_key_reference].sku
        sku_tier                = var.public_ip_configurations[pip.public_ip_key_reference].sku_tier
        zones                   = var.public_ip_configurations[pip.public_ip_key_reference].zones
        inherit_tags            = true
      }
    }
  }

  # =============================================================================
  # NAT Gateways to Provision
  # =============================================================================
  nat_gateways_to_provision = {
    for nat_key, nat in var.nat_gateways :
    nat_key => {
      name                    = local.nat_gateway_names[nat_key]
      location                = var.locations[nat.location_key_reference]
      parent_id               = module.resource_groups[nat.resource_group_key_reference].resource_id
      sku_name                = nat.sku_name
      idle_timeout_in_minutes = nat.idle_timeout_in_minutes
      zones                   = nat.sku_name == "StandardV2" ? null : nat.zones
      tags                    = local.nat_gateway_tags[nat_key]
      lock                    = local.nat_gateway_locks[nat_key]

      # Public IPs to create
      public_ips               = local.nat_gateway_public_ips[nat_key]
      public_ip_configuration  = local.nat_gateway_public_ip_config[nat_key]

      # Existing public IP and prefix resource IDs
      public_ip_resource_ids           = nat.public_ip_resource_ids
      public_ip_v6_resource_ids        = nat.public_ip_v6_resource_ids
      public_ip_prefix_resource_ids    = nat.public_ip_prefix_resource_ids
      public_ip_prefix_v6_resource_ids = nat.public_ip_prefix_v6_resource_ids
    }
  }
}
