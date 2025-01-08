module "vm_sets" {
  source   = "../ha_vm_set"
  for_each = var.virtualmachine_sets

  providers = {
    azurerm = azurerm
  }

  location             = each.value.location
  resource_prefix      = each.key
  resource_group_name  = each.value.resource_group_name
  resource_tags        = each.value.tags
  virtualmachine_count = each.value.count

  virtualmachine_data_disks = {
    for disk_name, disk_profile_name in var.virtualmachine_profiles[each.value.profile_name].data_disk_profiles :
    disk_name => {
      lun                  = index(keys(var.virtualmachine_profiles[each.value.profile_name].data_disk_profiles), disk_name)
      caching              = var.disk_profiles[disk_profile_name].caching
      storage_account_type = var.disk_profiles[disk_profile_name].storage_account_type
      disk_size_gb         = var.disk_profiles[disk_profile_name].disk_size_gb
    }
  }

  virtualmachine_network_interfaces = {
    for nic_name, nic_config in each.value.network_interfaces : nic_name => {
      subnet_id             = nic_config.subnet_id
      private_ip_allocation = nic_config.private_ip_allocation
    }
  }

  virtualmachine_image_reference = var.virtualmachine_profiles[each.value.profile_name].image_reference
  virtualmachine_os_disk         = var.disk_profiles[var.virtualmachine_profiles[each.value.profile_name].os_disk_profile]
  virtualmachine_os_type         = var.virtualmachine_profiles[each.value.profile_name].os_type
  virtualmachine_sku_size        = var.virtualmachine_profiles[each.value.profile_name].sku_size

  virtualmachine_spread_across_zones        = each.value.spread_across_zones
  virtualmachine_spread_evenly_across_zones = each.value.spread_evenly_across_zones
}
