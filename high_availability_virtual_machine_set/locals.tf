locals {
  lock_modes = {
    no_delete = "CanNotDelete"
    read_only = "ReadOnly"
  }

  virtual_machine_scale_set_name = "${var.resource_prefix}vmss"

  virtual_machine_names          = [for i in range(var.virtual_machine_count) : lower("${var.resource_prefix}${format("%02d", i + 1)}")]
  virtual_machine_computer_names = [for i in range(var.virtual_machine_count) : lower(substr("${var.resource_prefix}${format("%02d", i + 1)}", 0, 15))]

  virtual_machine_data_disks = [
    for i in range(var.virtual_machine_count) : {
      for disk_name, disk_config in var.virtual_machine_data_disks : disk_name => {
        name                      = lower("${local.virtual_machine_names[i]}${disk_name}disk")
        lock                      = var.lock_mode == null ? null : { kind = lookup(local.lock_modes, var.lock_mode, null) }
        tags                      = var.resource_tags
        caching                   = lookup(disk_config, "caching", "ReadWrite")
        storage_account_type      = lookup(disk_config, "storage_account_type", "PremiumV2_LRS")
        lun                       = disk_config.lun
        disk_size_gb              = disk_config.disk_size_gb
        create_option             = (disk_config.image == null ? "Empty" : (disk_config.image.copy != null ? "Copy" : (disk_config.image.import != null ? (disk_config.image.import.secure ? "ImportSecure" : "Import") : disk_config.image.platform != null ? "FromImage" : "Restore")))
        source_image_reference_id = (disk_config.image == null ? null : (disk_config.image.platform != null ? disk_config.image.platform.image_reference.id : null))
        source_resource_id        = (disk_config.image == null ? null : (disk_config.image.copy != null ? disk_config.image.copy.resource_id : (disk_config.image.restore != null ? disk_config.image.restore.resource_id : null)))
        source_uri                = (disk_config.image == null ? null : (disk_config.image.import != null ? disk_config.image.import.uri : null))
      }
    }
  ]

  virtual_machine_os_disks = [
    for i in range(var.virtual_machine_count) : {
      name                 = lower("${local.virtual_machine_names[i]}osdisk")
      tags                 = var.resource_tags
      caching              = lookup(var.virtual_machine_os_disk, "caching", "ReadWrite")
      storage_account_type = lookup(var.virtual_machine_os_disk, "storage_account_type", "PremiumV2_LRS")
      disk_size_gb         = lookup(var.virtual_machine_os_disk, "disk_size_gb", 128)
    }
  ]

  virtual_machine_network_interfaces = [
    for i in range(var.virtual_machine_count) : {
      for nic_name, nic_config in var.virtual_machine_network_interfaces : nic_name => {
        name                           = "${local.virtual_machine_names[i]}${nic_name}nic"
        lock                           = var.lock_mode == null ? null : { kind = lookup(local.lock_modes, var.lock_mode, null) }
        tags                           = var.resource_tags
        accelerated_networking_enabled = true
        ip_configurations = {
          ip_configuration_1 = {
            name                          = lower("${local.virtual_machine_names[i]}${nic_name}ipconfig01")
            private_ip_subnet_resource_id = nic_config.subnet_id
            private_ip_address_allocation = lookup(nic_config, "private_ip_allocation", "Dynamic")
            private_ip_address            = lookup(nic_config, "private_ip", null)
          }
        }
      }
    }
  ]

  virtual_machine_zones = [
    for i in range(var.virtual_machine_count) : (
      var.virtual_machine_zone_distribution.even != null ?
      var.virtual_machine_zone_distribution.even[i % length(var.virtual_machine_zone_distribution.even)] :
      flatten([for zone, count in var.virtual_machine_zone_distribution.custom : [for _ in range(count) : zone]])[i]
  )]
}
