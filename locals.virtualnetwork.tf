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

  networks = {
    for network_ref, network in var.virtual_networks : network_ref => {
      address_spaces         = coalesce(network.address_spaces, compact([network.address_space]))
      dns_ips                = network.dns_ip_addresses
      enable_ddos_protection = network.enable_ddos_protection
      location_key_reference = network.location_key_reference
      resource_group_key_reference = network.resource_group_key_reference
      name                   = local.network_names[network_ref]
      tags                   = network.tags

      lock = (
        length([
          for group in network.lock_groups_key_reference :
          # Apply a lock only if lock_groups specifies a locked group
          group if contains(keys(local.locked_groups), group)
        ]) > 0
        ? (
          anytrue([
            for group in network.lock_groups_key_reference :
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
          address_space                        = subnet.address_space
          name                                 = lower(coalesce(subnet.name, subnet_ref))
          route_table_key_reference            = subnet.route_table_key_reference
          network_security_group_key_reference = subnet.network_security_group_key_reference
        }
      }
    } if network != null
  }

  network_address_spaces = {
    for network_key, network in merge(var.virtual_networks, var.external_networks)
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
  # Step 1: Flatten peering relationships from var.virtual_networks
  vnet_peering_pairs_raw = flatten([
    for from_network_key, from_network in var.virtual_networks : [
      for to_network_key in from_network.peered_to : {
        key                = "peer-${from_network_key}-to-${to_network_key}"
        from_network_key   = from_network_key
        to_network_key     = to_network_key
        is_internal_target = contains(keys(var.virtual_networks), to_network_key)
        # Canonical key for deduplication - sort alphabetically so A-B and B-A get same canonical key
        canonical_key      = join("-", sort([from_network_key, to_network_key]))
      }
    ]
  ])

  # Step 2: Deduplicate internal peerings - only keep one direction per pair
  # For internal targets (both VNets managed by this module), the AVM module creates reverse peering automatically
  # So we only need one entry per pair - keep the one where from < to alphabetically
  vnet_peering_pairs = [
    for pair in local.vnet_peering_pairs_raw : pair
    if !pair.is_internal_target || pair.from_network_key < pair.to_network_key
  ]

  # Step 3: Build peering configurations from the deduplicated pairs
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

  # Networks to provision - consolidates all network configuration for the AVM module
  networks_to_provision = {
    for network_key, network in local.networks : network_key => {
      name                = network.name
      location            = var.locations[network.location_key_reference]
      address_space       = network.address_spaces
      parent_id           = module.resource_groups[network.resource_group_key_reference].resource_id
      tags                = local.network_tags[network_key]
      lock                = network.lock

      ddos_protection_plan = (
        network.enable_ddos_protection
        ? {
          id     = module.ddos_protection_plan[0].resource_id
          enable = true
        }
        : null
      )

      dns_servers = {
        dns_servers = (network.dns_ips == null ? null : network.dns_ips)
      }

      subnets = {
        for subnet_key, subnet in network.subnets :
        subnet_key => {
          name             = coalesce(subnet.name, subnet_key)
          address_prefixes = [subnet.address_space]

          network_security_group = (
            subnet.network_security_group_key_reference != null
            ? { id = module.network_security_groups[subnet.network_security_group_key_reference].resource_id }
            : null
          )

          route_table = (
            subnet.route_table_key_reference != null
            ? { id = module.route_tables[subnet.route_table_key_reference].resource_id }
            : null
          )
        }
      }
    }
  }

  # Route tables to provision - consolidates route table configuration for the AVM module
  route_tables_to_provision = {
    for table_key, table in local.route_tables : table_key => {
      name                = local.route_table_names[table_key]
      location            = var.locations[table.location_key_reference]
      resource_group_name = module.resource_groups[table.resource_group_key_reference].name
      lock                = table.lock
      tags                = local.route_table_tags[table_key]

      routes = {
        for route_ref, route in table.routes : route_ref => {
          name                   = route.route_name
          address_prefix         = route.address_prefix
          next_hop_type          = route.next_hop_type
          next_hop_in_ip_address = route.next_hop_ip_address
        }
      }
    }
  }

  # Network security groups to provision - consolidates NSG configuration for the AVM module
  network_security_groups_to_provision = {
    for nsg_key, nsg in local.network_security_groups : nsg_key => {
      name                = local.security_group_names[nsg_key]
      location            = var.locations[nsg.location_key_reference]
      resource_group_name = module.resource_groups[nsg.resource_group_key_reference].name
      lock                = nsg.lock
      tags                = local.security_group_tags[nsg_key]

      security_rules = {
        for rule_name, rule in nsg.security_rules :
        rule_name => {
          access                                     = rule.config.access
          direction                                  = rule.config.direction
          priority                                   = rule.priority
          protocol                                   = rule.config.protocol
          name                                       = rule_name
          destination_address_prefix                 = rule.config.destination_address_prefix
          destination_port_range                     = rule.config.destination_port_range
          source_address_prefix                      = rule.config.source_address_prefix
          source_port_range                          = rule.config.source_port_range

          destination_application_security_group_ids = (
            length(rule.config.destination_application_security_group_ids) == 0
            ? null : rule.config.destination_application_security_group_ids
          )

          destination_address_prefixes = (
            length(rule.config.destination_address_prefixes) == 0
            ? null : rule.config.destination_address_prefixes
          )

          source_address_prefixes = (
            length(rule.config.source_address_prefixes) == 0
            ? null : rule.config.source_address_prefixes
          )

          source_application_security_group_ids = (
            length(rule.config.source_application_security_group_ids) == 0
            ? null : rule.config.source_application_security_group_ids
          )

          destination_port_ranges = (
            length(rule.config.destination_port_ranges) == 0
            ? null : rule.config.destination_port_ranges
          )

          source_port_ranges = (
            length(rule.config.source_port_ranges) == 0
            ? null : rule.config.source_port_ranges
          )
        }
      }
    }
  }

  # Application security groups to provision
  application_security_groups_to_provision = {
    for name, vm_set in var.virtual_machine_sets : name => {
      name                = local.virtual_machine_set_asg_names[name]
      location            = var.locations[vm_set.location_key_reference]
      resource_group_name = module.resource_groups[vm_set.resource_group_key_reference].name
      tags                = local.virtual_machine_set_asg_tags[name]
    } if vm_set != null
  }

}
