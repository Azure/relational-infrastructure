# =============================================================================
# Load Balancers using AVM Module
# =============================================================================
module "load_balancers" {
  source   = "Azure/avm-res-network-loadbalancer/azurerm"
  version  = "0.5.0"
  for_each = local.load_balancers_to_provision

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku                 = each.value.sku
  sku_tier            = each.value.sku_tier
  tags                = each.value.tags
  lock                = each.value.lock

  frontend_ip_configurations      = each.value.frontend_ip_configurations
  public_ip_address_configuration = each.value.public_ip_address_configuration
  backend_address_pools           = each.value.backend_address_pools
  lb_probes                       = each.value.lb_probes
  lb_rules                        = each.value.lb_rules
  lb_nat_rules                    = each.value.nat_rules
}

# =============================================================================
# Activity Log Alerts for Load Balancer Changes
# =============================================================================
resource "azurerm_monitor_activity_log_alert" "load_balancer_activity_log_alerts" {
  for_each = local.load_balancers_to_provision

  name                = "${each.value.name}-changed-alert"
  resource_group_name = each.value.resource_group_name
  location            = "global"
  scopes              = [module.load_balancers[each.key].resource_id]
  tags                = each.value.tags
  description         = "This alert will monitor load balancer [${each.value.name}] for any changes."

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/loadBalancers/write"
    resource_id    = module.load_balancers[each.key].resource_id
  }
}
