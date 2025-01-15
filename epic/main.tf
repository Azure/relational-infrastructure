module "networks_resource_group" {
  source = "Azure/avm-res-resources-resourcegroup/azurerm"

  location = local.default_location
  name     = local.network_resource_group_name
  tags     = var.tags
}

module "networks" {
  source   = "Azure/avm-res-network-virtualnetwork/azurerm"
  for_each = var.networks

  location            = var.locations[each.value.location]
  name                = "${var.deployment_prefix}${replace(coalesce(each.value.name, each.key), "[^a-zA-Z0-9]", "")}"
  resource_group_name = module.networks_resource_group.name
  address_space       = each.value.address_space
  tags                = var.tags

  subnets = {
    for subnet_name, subnet in each.value.subnets : subnet_name => {
      address_space = subnet.address_space
      name          = coalesce(subnet.name, subnet_name)
    }
  }
}

resource "azurerm_virtual_network_peering" "peerings" {
  for_each = { for network_name, network in var.networks : network_name => network.peered_to }

  name                      = "peer-${each.key}-to-${each.value}"
  resource_group_name       = module.networks_resource_group.name
  virtual_network_name      = module.networks[each.key].name
  remote_virtual_network_id = module.networks[each.value].resource_id

  depends_on = [module.networks]
}

module "virtual_machine_set_resource_groups" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  for_each = var.virtual_machine_sets

  location = var.locations[each.value.location]
  name     = coalesce(each.value.resource_group_name, "${var.deployment_prefix}-${replace(coalesce(each.value.name, each.key), "[^a-zA-Z0-9]", "-")}")
  tags     = merge(var.tags, each.value.tags)
}

module "virtual_machine_sets" {
  source   = "../high_availability_virtual_machine_set"
  for_each = var.virtual_machine_sets

  location                                      = var.locations[each.value.location]
  resource_group_name                           = module.virtual_machine_set_resource_groups[each.key].name
  resource_prefix                               = "${var.deployment_prefix}${replace(coalesce(each.value.name, each.key), "[^a-zA-Z0-9]", "")}"
  resource_tags                                 = merge(var.tags, each.value.tags)
  virtual_machine_count                         = var.virtual_machine_set_specs[each.key].vm_count
  enable_virtual_machine_boot_diagnostics       = each.value.enable_boot_diagnostics
  virtual_machine_capacity_reservation_group_id = each.value.capacity_reservation_group_id
  virtual_machine_disk_controller_type          = each.value.disk_controller_type
  virtual_machine_image                         = each.value.image
  virtual_machine_os_type                       = each.value.os_type
  virtual_machine_sku_size                      = var.virtual_machine_set_specs[each.key].sku_size
  virtual_machine_zone_distribution             = lookup(var.virtual_machine_set_zone_distribution, each.key, { even = ["1", "2", "3"] })
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
    for nic_name, nic in each.network_interfaces : nic => {
      private_ip_allocation = nic.private_ip_allocation
      subnet_id             = module.networks[nic.network_name].subnets[nic.subnet_name].resource_id
    }
  }

  virtual_machine_os_disk = {
    disk_size_gb         = var.virtual_machine_set_specs[each.key].os_disk.disk_size_gb
    storage_account_type = var.virtual_machine_set_specs[each.key].os_disk.storage_account_type
  }
}
