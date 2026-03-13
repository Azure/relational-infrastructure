locals {
  lock_modes = {
    no_delete = "CanNotDelete"
    read_only = "ReadOnly"
  }

  vm_lock = (
    var.lock_mode == null ? null
    : { kind = lookup(local.lock_modes, var.lock_mode, null) }
  )

  vmss_lock = (
    var.lock_mode == null ? null
    : { kind = lookup(local.lock_modes, var.lock_mode, null) }
  )

  asg_lock = (
    var.lock_mode == null ? null
    : { kind = lookup(local.lock_modes, var.lock_mode, null) }
  )

  maintenance_configuration_name = "${var.resource_prefix}-mc"
  virtual_machine_scale_set_name = "${var.resource_prefix}-vmss"

  # Sort VMs by sequence_number for consistent zone distribution
  sorted_vm_keys = [
    for vm_key in keys(var.virtual_machines) : vm_key
  ]

  # Assign zones based on sequence_number
  virtual_machine_zones = {
    for vm_key, vm in var.virtual_machines : vm_key => (
      var.virtual_machine_zone_distribution.even != null
      ? var.virtual_machine_zone_distribution.even[(vm.sequence_number - 1) % length(var.virtual_machine_zone_distribution.even)]
      : flatten([for zone, count in var.virtual_machine_zone_distribution.custom : [for _ in range(count) : zone]])[vm.sequence_number - 1]
    )
  }

  # Group VMs by zone for naming
  virtual_machines_by_zone = {
    for zone in distinct(values(local.virtual_machine_zones)) :
    zone => [for vm_key, vm_zone in local.virtual_machine_zones : vm_key if vm_zone == zone]
  }

  # VM names using zone-based numbering
  virtual_machine_names = {
    for vm_key, vm in var.virtual_machines : vm_key =>
    lower("${var.resource_prefix}${local.virtual_machine_zones[vm_key]}${format("%02d", index(local.virtual_machines_by_zone[local.virtual_machine_zones[vm_key]], vm_key) + 1)}")
  }

  # Computer names (max 15 chars)
  virtual_machine_computer_names = {
    for vm_key, vm in var.virtual_machines : vm_key =>
    lower(substr("${var.resource_prefix}${format("%02d", vm.sequence_number)}", 0, 15))
  }

  # Data disks per VM
  virtual_machine_data_disks = {
    for vm_key, vm in var.virtual_machines : vm_key => {
      for disk_name, disk_config in var.virtual_machine_data_disks : disk_name => {
        name                      = lower("${local.virtual_machine_names[vm_key]}-${disk_name}-disk")
        tags                      = merge(var.resource_tags, disk_config.tags)
        caching                   = lookup(disk_config, "caching", "ReadWrite")
        storage_account_type      = lookup(disk_config, "storage_account_type", "PremiumV2_LRS")
        lun                       = disk_config.lun
        disk_size_gb              = disk_config.disk_size_gb
        create_option             = (disk_config.image == null ? "Empty" : (disk_config.image.copy != null ? "Copy" : (disk_config.image.import != null ? (disk_config.image.import.secure ? "ImportSecure" : "Import") : disk_config.image.platform != null ? "FromImage" : "Restore")))
        source_image_reference_id = (disk_config.image == null ? null : (disk_config.image.platform != null ? disk_config.image.platform.image_reference.id : null))
        source_resource_id        = (disk_config.image == null ? null : (disk_config.image.copy != null ? disk_config.image.copy.resource_id : (disk_config.image.restore != null ? disk_config.image.restore.resource_id : null)))
        source_uri                = (disk_config.image == null ? null : (disk_config.image.import != null ? disk_config.image.import.uri : null))

        lock_level = (
          var.lock_mode == null ? null
          : { kind = lookup(local.lock_modes, var.lock_mode, null) }
        )
      }
    }
  }

  # OS disks per VM
  virtual_machine_os_disks = {
    for vm_key, vm in var.virtual_machines : vm_key => {
      name                 = lower("${local.virtual_machine_names[vm_key]}-osdisk")
      tags                 = var.resource_tags
      caching              = lookup(var.virtual_machine_os_disk, "caching", "ReadWrite")
      storage_account_type = lookup(var.virtual_machine_os_disk, "storage_account_type", "PremiumV2_LRS")
      disk_size_gb         = lookup(var.virtual_machine_os_disk, "disk_size_gb", 128)
    }
  }

  # Network interfaces per VM
  virtual_machine_network_interfaces = {
    for vm_key, vm in var.virtual_machines : vm_key => {
      for nic_name, nic_config in var.virtual_machine_network_interfaces : nic_name => {
        name                           = "${local.virtual_machine_names[vm_key]}-${nic_name}-nic"
        lock                           = var.lock_mode == null ? null : { kind = lookup(local.lock_modes, var.lock_mode, null) }
        tags                           = var.resource_tags
        accelerated_networking_enabled = nic_config.enable_accelerated_networking

        ip_configurations = {
          ip_configuration_1 = {
            name                          = lower("${local.virtual_machine_names[vm_key]}-${nic_name}-ipcfg01")
            private_ip_subnet_resource_id = nic_config.subnet_id
            private_ip_address_allocation = lookup(nic_config, "private_ip", null) == null ? "Dynamic" : "Static"
            private_ip_address            = lookup(nic_config, "private_ip", null)
          }
        }

        lock_level = (
          nic_config.lock_mode == null ? null
          : lookup(local.lock_modes, nic_config.lock_mode, null)
        )
      }
    }
  }

  # Secret configurations per VM
  virtual_machine_secret_configs = var.key_vault_configuration == null ? {} : {
    for vm_key, vm in var.virtual_machines : vm_key => {
      key_vault_resource_id          = var.key_vault_configuration.resource_id
      name                           = var.key_vault_configuration.secret_configuration.name == null ? null : "${var.key_vault_configuration.secret_configuration.name}-${vm_key}"
      expiration_date_length_in_days = var.key_vault_configuration.secret_configuration.expiration_date_length_in_days
      content_type                   = var.key_vault_configuration.secret_configuration.content_type
      not_before_date                = var.key_vault_configuration.secret_configuration.not_before_date
      tags                           = var.key_vault_configuration.secret_configuration.tags
    }
  }
}
