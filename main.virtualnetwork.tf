module "ddos_protection_plan" {
  source  = "Azure/avm-res-network-ddosprotectionplan/azurerm"
  version = "0.3.0"
  count   = anytrue(values(var.virtual_networks)[*].enable_ddos_protection) ? 1 : 0

  location            = values(var.locations)[0]
  name                = "${var.deployment_prefix}-ddosplan"
  resource_group_name = module.resource_groups[var.default_resource_group_key_reference].name
}

module "networks" {
  source   = "Azure/avm-res-network-virtualnetwork/azurerm"
  version  = "0.17.1"
  for_each = local.networks_to_provision

  name                 = each.value.name
  location             = each.value.location
  address_space        = each.value.address_space
  parent_id            = each.value.parent_id
  tags                 = each.value.tags
  lock                 = each.value.lock
  ddos_protection_plan = each.value.ddos_protection_plan
  dns_servers          = each.value.dns_servers
  subnets              = each.value.subnets
}

module "route_tables" {
  source   = "Azure/avm-res-network-routetable/azurerm"
  version  = "0.5.0"
  for_each = local.route_tables_to_provision

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  lock                = each.value.lock
  tags                = each.value.tags
  routes              = each.value.routes
}

resource "azurerm_monitor_activity_log_alert" "route_table_activity_log_alerts" {
  for_each = local.route_tables_to_provision

  name                = "${each.value.name}-changed-alert"
  resource_group_name = each.value.resource_group_name
  location            = "global"
  scopes              = [module.route_tables[each.key].resource_id]
  tags                = each.value.tags
  description         = "This alert will monitor route table [${each.value.name}] for any changes."

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/routeTables/write"
    resource_id    = module.route_tables[each.key].resource_id
  }
}

module "network_security_groups" {
  source   = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version  = "0.5.1"
  for_each = local.network_security_groups_to_provision

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  lock                = each.value.lock
  tags                = each.value.tags
  security_rules      = each.value.security_rules
}

resource "azurerm_monitor_activity_log_alert" "network_security_group_activity_log_alerts" {
  for_each = local.network_security_groups_to_provision

  name                = "${each.value.name}-changed-alert"
  resource_group_name = each.value.resource_group_name
  location            = "global"
  scopes              = [module.network_security_groups[each.key].resource_id]
  tags                = each.value.tags
  description         = "This alert will monitor network security group [${each.value.name}] for any changes."

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/networkSecurityGroups/write"
    resource_id    = module.network_security_groups[each.key].resource_id
  }
}

# VNet Peering using AVM submodule
module "vnet_peerings" {
  source   = "Azure/avm-res-network-virtualnetwork/azurerm//modules/peering"
  version  = "0.17.1"
  for_each = local.vnet_peerings

  name                      = each.value.name
  parent_id                 = each.value.local_vnet_id
  remote_virtual_network_id = each.value.remote_vnet_id

  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  allow_virtual_network_access = each.value.allow_virtual_network_access
  use_remote_gateways          = each.value.use_remote_gateways

  # Create reverse peering only for internal-to-internal peerings
  create_reverse_peering               = each.value.create_reverse_peering
  reverse_name                         = each.value.reverse_name
  reverse_allow_forwarded_traffic      = each.value.reverse_allow_forwarded_traffic
  reverse_allow_gateway_transit        = each.value.reverse_allow_gateway_transit
  reverse_allow_virtual_network_access = each.value.reverse_allow_virtual_network_access
  reverse_use_remote_gateways          = each.value.reverse_use_remote_gateways
}

resource "azurerm_application_security_group" "application_security_group" {
  for_each = local.application_security_groups_to_provision

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tags                = each.value.tags
}
