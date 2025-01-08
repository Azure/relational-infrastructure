

locals {
  virtualmachinescaleset_name = "${var.resource_prefix}vmssflex"

  virtualmachine_names = [
    for i in range(var.virtualmachine_count) :
    lower("${var.resource_prefix}vm${format("%02d", i + 1)}")
  ]

  virtualmachine_computer_names = [
    for i in range(var.virtualmachine_count) :
    lower(substr("${var.resource_prefix}${format("%02d", i + 1)}", 0, 15))
  ]

  virtualmachine_data_disks = [
    for i in range(var.virtualmachine_count) : {
      for disk_name, disk_config in var.virtualmachine_data_disks : disk_name => {
        name                 = lower("${local.virtualmachine_names[i]}${disk_name}disk")
        tags                 = var.resource_tags
        caching              = lookup(disk_config, "caching", "ReadWrite")
        storage_account_type = lookup(disk_config, "storage_account_type", "PremiumV2_LRS")
        lun                  = disk_config.lun
        disk_size_gb         = disk_config.disk_size_gb
      }
    }
  ]

  virtualmachine_os_disks = [
    for i in range(var.virtualmachine_count) : {
      name                 = lower("${local.virtualmachine_names[i]}osdisk")
      tags                 = var.resource_tags
      caching              = lookup(var.virtualmachine_os_disk, "caching", "ReadWrite")
      storage_account_type = lookup(var.virtualmachine_os_disk, "storage_account_type", "PremiumV2_LRS")
      disk_size_gb         = lookup(var.virtualmachine_os_disk, "disk_size_gb", 128)
    }
  ]

  virtualmachine_networkinterfaces = [
    for i in range(var.virtualmachine_count) : {
      for nic_name, nic_config in var.virtualmachine_network_interfaces : nic_name => {
        name                           = "${local.virtualmachine_names[i]}${nic_name}nic"
        tags                           = var.resource_tags
        accelerated_networking_enabled = true
        ip_configurations = {
          ip_configuration_1 = {
            name                          = lower("${local.virtualmachine_names[i]}${nic_name}nicipconfig1")
            private_ip_subnet_resource_id = nic_config.subnet_id
            private_ip_address_allocation = lookup(nic_config, "private_ip_allocation", "Dynamic")
            private_ip_address            = lookup(nic_config, "private_ip", null)
          }
        }
      }
    }
  ]

  virtualmachine_zones = [
    for i in range(var.virtualmachine_count) :
    (
      var.virtualmachine_spread_across_zones == null ?
      var.virtualmachine_spread_evenly_across_zones[i % length(var.virtualmachine_spread_evenly_across_zones)] :
      flatten([
        for zone, count in var.virtualmachine_spread_across_zones : [
          for _ in range(count) : zone
      ]])[i]
    )
  ]
}
