# =============================================================================
# NAT Gateways using AVM Module
# =============================================================================
module "nat_gateways" {
  source   = "Azure/avm-res-network-natgateway/azurerm"
  version  = "0.3.2"
  for_each = local.nat_gateways_to_provision

  name                    = each.value.name
  location                = each.value.location
  parent_id               = each.value.parent_id
  sku_name                = each.value.sku_name
  idle_timeout_in_minutes = each.value.idle_timeout_in_minutes
  zones                   = each.value.zones
  tags                    = each.value.tags
  lock                    = each.value.lock

  # Public IPs to create for this NAT Gateway
  public_ips              = each.value.public_ips
  public_ip_configuration = each.value.public_ip_configuration

  # Existing public IP and prefix resource IDs
  public_ip_resource_ids           = each.value.public_ip_resource_ids
  public_ip_v6_resource_ids        = each.value.public_ip_v6_resource_ids
  public_ip_prefix_resource_ids    = each.value.public_ip_prefix_resource_ids
  public_ip_prefix_v6_resource_ids = each.value.public_ip_prefix_v6_resource_ids
}

# Activity log alerts for NAT Gateway changes
resource "azurerm_monitor_activity_log_alert" "nat_gateway_activity_log_alerts" {
  for_each = local.nat_gateways_to_provision

  name                = "${each.value.name}-changed-alert"
  resource_group_name = module.resource_groups[var.nat_gateways[each.key].resource_group_key_reference].name
  location            = "global"
  scopes              = [module.nat_gateways[each.key].resource_id]
  tags                = each.value.tags
  description         = "This alert will monitor NAT Gateway [${each.value.name}] for any changes."

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/natGateways/write"
    resource_id    = module.nat_gateways[each.key].resource_id
  }
}
