module "alt_virtual_machine_sets" {
  source   = "../high_availability_virtual_machine_set"
  for_each = var.virtual_machine_sets.alt

  location                                      = var.alt_location
  resource_group_name                           = each.value.resource_group_name
  resource_prefix                               = "${var.deployment_prefix}${var.location_prefixes[lower(var.alt_location)]}${each.value.resource_prefix}"
  resource_tags                                 = each.value.tags
  virtual_machine_count                         = each.value.vm_count
  enable_virtual_machine_boot_diagnostics       = each.value.enable_boot_diagnostics
  virtual_machine_capacity_reservation_group_id = each.value.capacity_reservation_group_id
  virtual_machine_disk_controller_type          = each.value.disk_controller_type
  virtual_machine_image                         = each.value.image
  virtual_machine_os_type                       = each.value.os_type
  virtual_machine_sku_size                      = var.cloud_specs_guide.alt[each.key].sku_size
  virtual_machine_zone_distribution             = var.virtual_machine_set_zone_distribution.alt[each.key]

  virtual_machine_data_disks = {
    for disk_name, disk_config in each.data_disks : disk_name => {
      caching              = disk_config.caching
      image                = disk_config.image
      lun                  = disk_config.lun
      disk_size_gb         = var.cloud_specs_guide.alt[each.key].data_disks[disk_name].disk_size_gb
      storage_account_type = var.cloud_specs_guide.alt[each.key].data_disks[disk_name].storage_account_type
    }
  }

  virtual_machine_network_interfaces = {
    for nic_name, nic_config in each.network_interfaces : nic_name => {
      private_ip_allocation = nic_config.private_ip_allocation
      subnet_id             = nic_config.subnet_id
    }
  }

  virtual_machine_os_disk = {
    disk_size_gb         = var.cloud_specs_guide.alt[each.key].os_disk.disk_size_gb
    storage_account_type = var.cloud_specs_guide.alt[each.key].os_disk.storage_account_type
  }
}
