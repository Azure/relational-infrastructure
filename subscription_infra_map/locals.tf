locals {
  # We only use [default_location] in places that are theoretically inconsequential, 
  # like resource group locations.

  default_location = values(var.locations)[0]

  private_link_resource_group_name = coalesce(
    var.private_link_resource_group_name,
    var.default_resource_group_name
  )

  networks = {
    for network_ref, network in var.networks : network_ref => {
      address_space          = network.address_space
      dns_ips                = network.dns_ip_addresses
      enable_ddos_protection = network.enable_ddos_protection
      location_ref           = network.location_name
      resource_group_name    = network.resource_group_name
      name                   = local.network_names[network_ref]


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
    for network_name, network in merge(var.networks, var.external_networks)
    : network_name => {
      address_space = network.address_space

      subnets = {
        for subnet_name, subnet in network.subnets
        : subnet_name => {
          address_space = subnet.address_space
        }
      }
    } if network != null
  }
}
