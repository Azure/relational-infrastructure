locals {
  route_tables = tomap({
    for table in flatten([
      for network_ref, network in local.networks : [
        for subnet_ref, subnet in network.subnets : {
          location_ref        = network.location_ref
          network_ref         = network_ref
          subnet_ref          = subnet_ref
          name                = local.route_table_names[network_ref][subnet_ref]
          resource_group_name = network.resource_group_name

          routes = {
            for route_ref, route in coalesce(subnet.routes, {}) : route_ref => {
              route_name = coalesce(route.route_name, route_ref)

              address_prefix = (
                route.destined_for.address_space != null ?
                route.destined_for.address_space : (
                  route.destined_for.network != null ?
                  local.network_address_spaces[route.destined_for.network.network_name].address_space :
                  local.network_address_spaces[route.destined_for.subnet.network_name].subnets[route.destined_for.subnet.subnet_name].address_space
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
        } if subnet.routes != null
      ] if network != null
    ]) : "${table.network_ref}_${table.subnet_ref}" => table
  })
}
