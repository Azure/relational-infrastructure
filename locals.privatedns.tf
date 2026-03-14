locals {
  # Unified virtual network links per DNS zone
  # Zone defines defaults, network can override per-zone
  dns_zone_virtual_network_links = {
    for zone_key, zone in var.private_dns_zones : zone_key => {
      for network_key, network in var.virtual_networks :
      network_key => {
        name               = "${network_key}_link_to_${zone.domain_name}"
        virtual_network_id = module.networks[network_key].resource_id
        registration_enabled = coalesce(
          try(network.private_dns_zones[zone_key].registration_enabled, null),
          zone.registration_enabled
        )
        resolution_policy = coalesce(
          try(network.private_dns_zones[zone_key].resolution_policy, null),
          zone.resolution_policy
        )
      } if contains(keys(try(network.private_dns_zones, {})), zone_key)
    }
  }

  # Private DNS zones to provision - only zones without resource_id_existing and when create is enabled
  private_dns_zones_to_provision = {
    for zone_key, zone in var.private_dns_zones : zone_key => {
      domain_name = zone.domain_name
      parent_id   = module.resource_groups[zone.resource_group_key_reference].resource_id
      tags        = merge(var.tags, { "zone_name" = zone_key })

      virtual_network_links = {
        for link_key, link in local.dns_zone_virtual_network_links[zone_key] :
        link_key => {
          name                 = link.name
          virtual_network_id   = link.virtual_network_id
          registration_enabled = link.registration_enabled
          resolution_policy    = link.resolution_policy
        }
      }
    } if var.private_dns_zones_create_enabled && zone.resource_id_existing == null
  }

  # Resource ID lookup - returns either module output or existing resource ID
  private_dns_zone_resource_ids = {
    for zone_key, zone in var.private_dns_zones : zone_key => (
      zone.resource_id_existing != null
      ? zone.resource_id_existing
      : module.private_dns_zones[zone_key].resource_id
    )
  }
}
