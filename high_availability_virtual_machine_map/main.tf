module "networks_resource_group" {
  source = "Azure/avm-res-resources-resourcegroup/azurerm"

  location = local.default_location
  name     = local.network_resource_group_name
  tags     = var.tags
}

module "networks" {
  source   = "Azure/avm-res-network-virtualnetwork/azurerm"
  for_each = var.networks

  location            = var.locations[each.value.location_name]
  name                = "${var.deployment_prefix}-${coalesce(each.value.name, each.key)}"
  resource_group_name = module.networks_resource_group.name
  address_space       = [each.value.address_space]
  tags                = merge(var.tags, (var.include_label_tags ? { network_label = each.key } : {}))

  subnets = {
    for subnet_name, subnet in each.value.subnets : subnet_name => {
      address_prefix = subnet.address_space
      name           = coalesce(subnet.name, subnet_name)
    }
  }
}

resource "azurerm_network_security_group" "network_security_groups" {
  for_each = tomap({
    for group_config in flatten([
      for network_name, network in var.networks : [
        for subnet_name, subnet in network.subnets : {
          location_name       = network.location_name
          security_group_name = "${var.deployment_prefix}-${coalesce(subnet.security_group_name, "${network_name}-${subnet_name}-nsg")}"
          network_name        = network_name
          subnet_name         = subnet_name
        }
      ]
    ]) : "${group_config.network_name}_${group_config.subnet_name}" => group_config
  })

  location            = var.locations[each.value.location_name]
  name                = each.value.security_group_name
  resource_group_name = local.network_resource_group_name
  tags                = merge(var.tags, (var.include_label_tags ? { network_label = each.value.network_name } : {}))
}

resource "azurerm_network_security_rule" "network_security_rules" {
  for_each = tomap({
    for rule_config in flatten([
      for network_name, network in var.networks : [
        for subnet_name, subnet in network.subnets : [
          for rule_name, rule in subnet.security_rules : {
            location_name = network.location_name
            network_name  = network_name
            subnet_name   = subnet_name
            rule_name     = rule_name
            rule          = rule
          }
        ]
      ]
    ]) : "${rule_config.network_name}_${rule_config.subnet_name}_${rule_config.rule_name}" => rule_config
  })

  access                       = each.value.rule.access
  direction                    = each.value.rule.direction
  name                         = each.value.rule_name
  network_security_group_name  = azurerm_network_security_group.network_security_groups["${each.value.network_name}_${each.value.subnet_name}"].name
  priority                     = each.value.rule.priority
  protocol                     = each.value.rule.protocol
  resource_group_name          = local.network_resource_group_name
  destination_address_prefix   = (each.value.rule.destination.subnet == null ? each.value.rule.destination.address_space : var.networks[each.value.network_name].subnets[each.value.rule.destination.subnet.subnet_name].address_space)
  destination_address_prefixes = each.value.rule.destination.address_spaces
  destination_port_range       = (each.value.destination.port_ranges == null ? each.value.rule.destination.port_range : null)
  destination_port_ranges      = each.value.rule.destination.port_ranges
  source_address_prefix        = (each.value.rule.source.subnet == null ? each.value.rule.source.address_space : var.networks[each.value.network_name].subnets[each.value.rule.source.subnet.subnet_name].address_space)
  source_address_prefixes      = each.value.rule.source.address_spaces
  source_port_range            = (each.value.source.port_ranges == null ? each.value.rule.source.port_range : null)
  source_port_ranges           = each.value.rule.source.port_ranges
}

resource "azurerm_virtual_network_peering" "peerings" {
  for_each = tomap({
    for peering in flatten([
      for from_network_name, from_network in var.networks : [
        for to_network_name in from_network.peered_to : {
          peer_from_network_name = from_network_name
          peer_to_network_name   = to_network_name
        }
      ]
    ]) : "peer-${peering.peer_from_network_name}-to-${peering.peer_to_network_name}" => peering
  })

  name                      = each.key
  resource_group_name       = module.networks_resource_group.name
  virtual_network_name      = module.networks[each.value.peer_from_network_name].name
  remote_virtual_network_id = module.networks[each.value.peer_to_network_name].resource_id

  depends_on = [module.networks]
}

module "virtual_machine_set_resource_groups" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  for_each = var.virtual_machine_sets

  location = var.locations[each.value.location_name]
  name     = "${var.deployment_prefix}-${coalesce(each.value.resource_group_name, each.key)}"
  tags     = merge(var.tags, each.value.tags, (var.include_label_tags ? { vm_set_label = each.key } : {}))
}

module "virtual_machine_sets" {
  source   = "../high_availability_virtual_machine_set"
  for_each = var.virtual_machine_sets

  location                                      = var.locations[each.value.location_name]
  resource_group_name                           = module.virtual_machine_set_resource_groups[each.key].name
  resource_prefix                               = "${var.deployment_prefix}${coalesce(each.value.name, each.key)}"
  resource_tags                                 = merge(var.tags, each.value.tags, (var.include_label_tags ? { vm_set_label = each.key } : {}))
  virtual_machine_count                         = var.virtual_machine_set_specs[each.key].vm_count
  enable_virtual_machine_boot_diagnostics       = each.value.enable_boot_diagnostics
  virtual_machine_capacity_reservation_group_id = each.value.capacity_reservation_group_id
  virtual_machine_disk_controller_type          = each.value.disk_controller_type
  virtual_machine_image                         = each.value.image
  virtual_machine_os_type                       = each.value.os_type
  virtual_machine_sku_size                      = var.virtual_machine_set_specs[each.key].sku_size
  virtual_machine_zone_distribution             = lookup(var.virtual_machine_set_zone_distribution, each.key, { custom = null, even = ["1", "2", "3"] })
  #                                               By default, unless overridden by [var.virtual_machine_set_zone_distribution], 
  #                                               zone distribution is always even across all 3 zones.

  virtual_machine_data_disks = {
    for disk_name, disk in each.value.data_disks : disk_name => {
      caching              = disk.caching
      image                = disk.image
      lun                  = disk.lun
      disk_size_gb         = var.virtual_machine_set_specs[each.key].data_disks[disk_name].disk_size_gb
      storage_account_type = var.virtual_machine_set_specs[each.key].data_disks[disk_name].storage_account_type
    }
  }

  virtual_machine_network_interfaces = {
    for nic_name, nic in each.value.network_interfaces : nic_name => {
      private_ip_allocation = nic.private_ip_allocation
      subnet_id             = module.networks[nic.network_name].subnets[nic.subnet_name].resource_id
    }
  }

  virtual_machine_os_disk = {
    disk_size_gb         = var.virtual_machine_set_specs[each.key].os_disk.disk_size_gb
    storage_account_type = var.virtual_machine_set_specs[each.key].os_disk.storage_account_type
  }
}
