locals {
  route_tables = {
    for table_key, table in var.route_tables : table_key => {
      location_key_reference       = table.location_key_reference
      resource_group_key_reference = table.resource_group_key_reference
      lock_groups_key_reference    = table.lock_groups_key_reference
      tags                         = table.tags

      lock = (
        length([
          for group in table.lock_groups_key_reference :
          group if contains(keys(local.locked_groups), group)
        ]) > 0
        ? (
          anytrue([
            for group in table.lock_groups_key_reference :
            contains(keys(local.locked_groups), group)
            && try(local.locked_groups[group].read_only, false)
          ])
          ? { kind = local.lock_modes.read_only }
          : { kind = local.lock_modes.no_delete }
        )
        : null
      )

      routes = {
        for route_ref, route in table.routes : route_ref => {
          route_name = coalesce(route.route_name, route_ref)

          address_prefix = (
            route.destined_for.address_space != null ?
            route.destined_for.address_space : (
              route.destined_for.network != null ?
              local.network_address_spaces[route.destined_for.network.network_key_reference].address_space :
              local.network_address_spaces[route.destined_for.subnet.network_key_reference].subnets[route.destined_for.subnet.subnet_key_reference].address_space
            )
          )

          next_hop_type = (
            route.to_gateway ?
            "VirtualNetworkGateway" : (
              route.to_internet ?
              "Internet" : (
                route.to_appliance != null ?
                "VirtualAppliance" :
                "None"
              )
            )
          )

          next_hop_ip_address = (
            route.to_appliance != null ?
            route.to_appliance.ip_address :
            null
          )
        }
      }
    }
  }
}
