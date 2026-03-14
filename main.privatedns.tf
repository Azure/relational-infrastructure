# Private DNS Zones using AVM module
module "private_dns_zones" {
  source   = "Azure/avm-res-network-privatednszone/azurerm"
  version  = "0.5.0"
  for_each = local.private_dns_zones_to_provision

  domain_name           = each.value.domain_name
  parent_id             = each.value.parent_id
  tags                  = each.value.tags
  virtual_network_links = each.value.virtual_network_links
}
