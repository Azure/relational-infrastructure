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
}
