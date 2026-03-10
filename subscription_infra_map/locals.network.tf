locals {
  internal_network_resource_ids = {
    for network_key, network in local.networks :
    network_key => {
      resource_id = module.networks[network_key].resource_id

      subnets = {
        for subnet_key, subnet in network.subnets :
        subnet_key => {
          resource_id = module.networks[network_key].subnets[subnet_key].resource_id
        }
      }
    } if network != null
  }

  external_network_resource_ids = {
    for network_key, network in var.external_networks :
    network_key => {
      resource_id = network.resource_id

      subnets = {
        for subnet_key, subnet in network.subnets :
        subnet_key => {
          resource_id = "${trimsuffix(network.resource_id, "/")}/subnets/${coalesce(subnet.name, subnet_key)}"
        }
      }
    } if try(network.resource_id, null) != null
  }

  network_resource_ids = merge(
    local.internal_network_resource_ids,
    local.external_network_resource_ids
  )

  # Build virtual network links per DNS zone for the AVM module
  # Registration links: networks that use this zone for VM auto-registration
  registration_links_by_zone = {
    for zone_key, zone in var.private_dns_zones : zone_key => {
      for network_key, network in var.networks :
      "${network_key}_registration" => {
        network_key          = network_key
        registration_enabled = true
      } if try(network.private_dns_zones.registration_zone_name, null) == zone_key
    }
  }

  # Resolution links: networks that use this zone for private link resolution
  resolution_links_by_zone = {
    for zone_key, zone in var.private_dns_zones : zone_key => {
      for network_key, network in var.networks :
      "${network_key}_resolution" => {
        network_key          = network_key
        registration_enabled = false
      } if(
        network.private_dns_zones != null &&
        contains(
          concat(
            compact([try(network.private_dns_zones.resolution_zone_name, null)]),
            try(network.private_dns_zones.resolution_zone_names, [])
          ),
          zone_key
        )
      )
    }
  }

  # Combined virtual network links per zone for the AVM module
  dns_zone_virtual_network_links = {
    for zone_key, zone in var.private_dns_zones : zone_key => merge(
      {
        for link_key, link in local.registration_links_by_zone[zone_key] :
        link_key => {
          name                 = "${link.network_key}_registration_link_to_${zone.domain_name}"
          virtual_network_id   = module.networks[link.network_key].resource_id
          registration_enabled = true
        }
      },
      {
        for link_key, link in local.resolution_links_by_zone[zone_key] :
        link_key => {
          name                 = "${link.network_key}_resolution_link_to_${zone.domain_name}"
          virtual_network_id   = module.networks[link.network_key].resource_id
          registration_enabled = false
        }
      }
    )
  }

  networks = {
    for network_ref, network in var.networks : network_ref => {
      address_spaces         = coalesce(network.address_spaces, compact([network.address_space]))
      dns_ips                = network.dns_ip_addresses
      enable_ddos_protection = network.enable_ddos_protection
      location_key          = network.location_key
      resource_group_key    = network.resource_group_key
      name                   = local.network_names[network_ref]
      tags                   = network.tags

      lock = (
        length([
          for group in network.lock_groups :
          # Apply a lock only if lock_groups specifies a locked group
          group if contains(keys(local.locked_groups), group)
        ]) > 0
        ? (
          anytrue([
            for group in network.lock_groups :
            # Apply a lock only if the group is locked
            # Read-only is the most restrictive lock. If any group is read-only, apply it.
            # Otherwise, apply a no-delete lock.
            contains(keys(local.locked_groups), group)
            && try(local.locked_groups[group].read_only, false)
          ])
          ? { kind = local.lock_modes.read_only }
          : { kind = local.lock_modes.no_delete }
        )
        : null
      )

      subnets = {
        for subnet_ref, subnet in network.subnets : subnet_ref => {
          address_space       = subnet.address_space
          name                = lower(coalesce(subnet.name, subnet_ref))
          security_group_name = subnet.security_group_name
          security_rules      = subnet.security_rules
          route_table_name    = subnet.route_table_name
          routes              = subnet.route_traffic
        }
      }
    } if network != null
  }

  network_address_spaces = {
    for network_key, network in merge(var.networks, var.external_networks)
    : network_key => {
      address_spaces = toset(coalesce(network.address_spaces, compact([network.address_space])))

      subnets = {
        for subnet_key, subnet in network.subnets
        : subnet_key => {
          address_space = tostring(subnet.address_space)
        }
      }
    } if network != null
  }

  # VNet peering configurations
  # Step 1: Flatten peering relationships from var.networks
  vnet_peering_pairs = flatten([
    for from_network_key, from_network in var.networks : [
      for to_network_key in from_network.peered_to : {
        key                = "peer-${from_network_key}-to-${to_network_key}"
        from_network_key   = from_network_key
        to_network_key     = to_network_key
        is_internal_target = contains(keys(var.networks), to_network_key)
      }
    ]
  ])

  # Step 2: Build peering configurations from the flattened pairs
  vnet_peerings = {
    for peering in local.vnet_peering_pairs : peering.key => {
      name          = peering.key
      local_vnet_id = module.networks[peering.from_network_key].resource_id

      # Remote VNet ID: use module output for internal networks, var.external_networks.resource_id for external
      remote_vnet_id = (
        peering.is_internal_target
        ? module.networks[peering.to_network_key].resource_id
        : var.external_networks[peering.to_network_key].resource_id
      )

      # Peering settings - defaults for standard connectivity
      allow_forwarded_traffic      = true
      allow_gateway_transit        = false
      allow_virtual_network_access = true
      use_remote_gateways          = false

      # Reverse peering only for internal-to-internal (we manage both VNets)
      create_reverse_peering               = peering.is_internal_target
      reverse_name                         = peering.is_internal_target ? "peer-${peering.to_network_key}-to-${peering.from_network_key}" : null
      reverse_allow_forwarded_traffic      = peering.is_internal_target
      reverse_allow_gateway_transit        = false
      reverse_allow_virtual_network_access = true
      reverse_use_remote_gateways          = false
    }
  }

}
