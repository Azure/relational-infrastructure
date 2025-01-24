locals {
  # We only use [default_location] in places that are theoretically inconsequential, 
  # like resource group locations.

  default_location = values(var.locations)[0]

  lock_modes = {
    no_delete = "CanNotDelete"
    read_only = "ReadOnly"
  }

  network_resource_groups = {
    for location_ref, location in var.locations : location_ref => {
      location = location
      name     = "${var.deployment_prefix}-${location}-networks"
    }
  }

  networks = {
    for network_ref, network in var.networks : network_ref => {
      address_space       = network.address_space
      location_ref        = network.location_name
      name                = lower(coalesce(network.name, "${var.deployment_prefix}-${network_ref}"))
      resource_group_name = local.network_resource_groups[network.location_name].name

      subnets = {
        for subnet_ref, subnet in network.subnets : subnet_ref => {
          address_space       = subnet.address_space
          name                = lower(coalesce(subnet.name, subnet_ref))
          security_group_name = subnet.security_group_name
          security_rules      = subnet.security_rules
        }
      }
    } if network != null
  }

  route_tables = {
    for network_ref, network in var.networks : network_ref => {
      for subnet_ref, subnet in network.subnets : subnet_ref => {
        location_ref = network.location_name
        network_ref  = network_ref
        subnet_ref   = subnet_ref
        name         = lower("${var.deployment_prefix}-${network.name}-${subnet.name}-routes")

        routes = {
          for route_ref, route in subnet.route_traffic : route_ref => {
            name = lower(coalesce(route.name, route_ref))

            address_prefix = (
              route.destined_for.address_space != null ? route.destined_for.address_space : (
                route.destined_for.network != null ? module.networks[route.destined_for.network.network_name].address_space :
                module.networks[route.destined_for.subnet.network_name].subnets[route.destined_for.subnet.subnet_name].address_space
              )
            )

            next_hop_type = (
              route.to_internet ? "Internet" : (
                route.to_nowhere ? "None" : (
                  route.to_local_network ? "VnetLocal" : (
                    route.to_gateway ? "VirtualNetworkGateway" :
                    "VirtualAppliance"
                  )
                )
              )
            )

            next_hop_ip_address = route.to_appliance != null ? route.to_appliance.ip_address : null
          }
        }
      } if subnet.route_traffic != null
    }
  }
}
