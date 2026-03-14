locals {
  # =============================================================================
  # Data Disk Configuration
  # =============================================================================
  data_disk_configs = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => {
      for disk in flatten([
        for disk_group_name, disk_group in vm_set.data_disk_groups : [
          for disk_index in range(var.virtual_machine_set_specs[vm_set_name].data_disk_groups[disk_group_name].disk_count) : {
            disk_index                    = disk_index
            vm_set_name                   = vm_set_name
            disk_group_name               = disk_group_name
            caching                       = disk_group.caching
            image                         = disk_group.image
            enable_public_network_access  = disk_group.enable_public_network_access
            disk_encryption_set_id        = disk_group.disk_encryption_set_id
            lock_groups_key_reference     = disk_group.lock_groups_key_reference
            disk_iops_read_only           = var.virtual_machine_set_specs[vm_set_name].data_disk_groups[disk_group_name].disk_iops_read_only
            disk_iops_read_write          = var.virtual_machine_set_specs[vm_set_name].data_disk_groups[disk_group_name].disk_iops_read_write
            disk_size_gb                  = var.virtual_machine_set_specs[vm_set_name].data_disk_groups[disk_group_name].disk_size_gb
            storage_account_type          = var.virtual_machine_set_specs[vm_set_name].data_disk_groups[disk_group_name].storage_account_type

            tags = {
              disk_group_label = disk_group_name
            }
          }
        ]
      ]) : "${disk.disk_group_name}-${disk.disk_index}" => disk
    }
  }

  data_disk_luns = {
    for vm_set_name, disks in local.data_disk_configs :
    vm_set_name => {
      for lun, disk_name in sort(keys(disks)) :
      disk_name => lun
    }
  }

  data_disks = {
    for vm_set_name, disks in local.data_disk_configs :
    vm_set_name => {
      for disk_name, disk_config in disks :
      disk_name => merge(
        disk_config,
        { lun = local.data_disk_luns[vm_set_name][disk_name] }
      )
    }
  }

  # Compute data disks with lock modes for each VM set
  virtual_machine_data_disks = {
    for vm_set_name, disks in local.data_disks :
    vm_set_name => {
      for disk_name, disk in disks : disk_name => {
        caching                      = disk.caching
        image                        = disk.image
        lun                          = disk.lun
        disk_size_gb                 = disk.disk_size_gb
        storage_account_type         = disk.storage_account_type
        enable_public_network_access = disk.enable_public_network_access
        disk_iops_read_only          = disk.disk_iops_read_only
        disk_iops_read_write         = disk.disk_iops_read_write
        disk_encryption_set_id       = disk.disk_encryption_set_id
        tags                         = disk.tags
        lock_mode                    = local.lock_modes[disk.lock_groups_key_reference]
      }
    }
  }

  # =============================================================================
  # Network Interface Configuration
  # =============================================================================
  virtual_machine_network_interfaces = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => {
      for nic_name, nic in vm_set.network_interfaces : nic_name => {
        private_ip                    = nic.private_ip
        enable_accelerated_networking = nic.enable_accelerated_networking
        subnet_id                     = local.network_resource_ids[nic.network_key_reference].subnets[nic.subnet_key_reference].resource_id
        lock_mode                     = local.lock_modes[nic.lock_groups_key_reference]
      }
    }
  }

  # =============================================================================
  # VM Set Extensions
  # =============================================================================
  virtual_machine_set_extensions = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => {
      for extension_name in vm_set.extensions_by_key_reference :
      extension_name => var.virtual_machine_extensions[extension_name]
    }
  }

  # =============================================================================
  # Key Vault Configuration for Generated Secrets
  # =============================================================================
  virtual_machine_key_vault_configs = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => {
      resource_id = coalesce(
        vm_set.key_vault_resource_id_existing,
        module.key_vaults[vm_set.key_vault_key_reference].resource_id
      )
      secret_configuration = {
        name                           = "vm-${replace(vm_set_name, "/[^a-zA-Z0-9-]/", "")}-creds"
        expiration_date_length_in_days = 90
        content_type                   = "password"
        not_before_date                = null
        tags                           = merge(var.tags, vm_set.tags, { credential_type = "generated" })
      }
    }
  }

  maintenance_schedule_recurrence = {
    for schedule_key, schedule in var.maintenance_schedules :
    schedule_key => (
      schedule.repeat_every.day
      ? "Day"
      : (
        schedule.repeat_every.week
        ? "Week"
        : (
          schedule.repeat_every.month
          ? "Month"
          : (
            schedule.repeat_every.days != null
            ? "${schedule.repeat_every.days}Days"
            : (
              schedule.repeat_every.weeks != null
              ? "${schedule.repeat_every.weeks}Weeks"
              : "${schedule.repeat_every.months}Months"
            )
          )
        )
      )
    )
  }

  maintenance_schedules = {
    for schedule_key, schedule in var.maintenance_schedules :
    schedule_key => {
      duration        = schedule.duration
      recur_every     = local.maintenance_schedule_recurrence[schedule_key]
      start_date_time = schedule.start_date_time_utc
      time_zone       = "UTC"

      expiration_date_time = (
        schedule.expiration_date_time_utc != null
        ? schedule.expiration_date_time_utc
        : null
      )
    }
  }

  vm_set_maintenance_configurations = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => {
      schedule            = local.maintenance_schedules[vm_set.maintenance.schedule_key_reference]
      scope               = "InGuestPatch"
      location_key       = vm_set.location_key_reference
      resource_group_key = vm_set.resource_group_key_reference
      schedule_key       = vm_set.maintenance.schedule_key_reference
      vm_set_name         = vm_set_name
    } if try(vm_set.maintenance.schedule_key_reference, null) != null
  }

  vm_set_shutdown_schedules = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => {
      for sched_name, sched_config in var.virtual_machine_shutdown_schedules : sched_name => {
        enabled               = sched_config.enabled
        daily_recurrence_time = sched_config.daily_recurrence_time
        timezone              = sched_config.timezone
        notification_settings = sched_config.notification_settings
      }
    } if try(vm_set.shutdown_schedule_key, null) != null
  }

  # =============================================================================
  # VM Sets to Provision - Main computed configuration
  # =============================================================================
  virtual_machine_sets_to_provision = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => {
      # Core settings
      location            = var.locations[vm_set.location_key_reference]
      resource_group_name = module.resource_groups[vm_set.resource_group_key_reference].name
      resource_group_id   = module.resource_groups[vm_set.resource_group_key_reference].resource_id
      resource_tags       = local.virtual_machine_set_tags[vm_set_name]
      virtual_machines    = var.virtual_machine_set_specs[vm_set_name].virtual_machines
      deploy_scale_set    = vm_set.deploy_scale_set

      # Resource prefix
      resource_prefix = (
        vm_set.include_deployment_prefix_in_name
        ? "${var.deployment_prefix}${coalesce(vm_set.name, vm_set_name)}"
        : coalesce(vm_set.name, vm_set_name)
      )

      # VM configuration
      virtual_machine_extensions_automatic_updates_enabled = var.virtual_machine_extensions_automatic_updates_enabled
      enable_boot_diagnostics                 = vm_set.enable_boot_diagnostics
      user_assigned_identity_ids              = var.virtual_machine_user_assigned_identity_resource_ids
      virtual_machine_system_assigned_identity_enabled = var.virtual_machine_system_assigned_identity_enabled
      capacity_reservation_group_id           = vm_set.capacity_reservation_group_id
      disk_controller_type                    = vm_set.disk_controller_type
      virtual_machine_image                   = var.virtual_machine_images[vm_set.image_key_reference]
      os_type                                 = vm_set.os_type
      sku_size                                = var.virtual_machine_set_specs[vm_set_name].sku_size

      # Zone distribution - default to even across all 3 zones
      zone_distribution = coalesce(
        try(var.virtual_machine_set_zone_distribution[vm_set_name], null),
        { custom = null, even = ["1", "2", "3"] }
      )

      # Maintenance and shutdown schedules
      maintenance_configuration = (
        try(vm_set.maintenance.schedule_key_reference, null) == null ? null
        : local.vm_set_maintenance_configurations[vm_set_name]
      )
      shutdown_schedule = (
        try(vm_set.shutdown_schedule_key_reference, null) == null ? null
        : local.vm_set_shutdown_schedules[vm_set_name]
      )

      # Lock mode
      lock_mode = local.lock_modes[vm_set.lock_groups_key_reference]

      # Key Vault configuration for generated secrets
      key_vault_configuration = local.virtual_machine_key_vault_configs[vm_set_name]

      # Extensions, disks, NICs, OS disk
      extensions         = local.virtual_machine_set_extensions[vm_set_name]
      data_disks         = local.virtual_machine_data_disks[vm_set_name]
      network_interfaces = local.virtual_machine_network_interfaces[vm_set_name]

      os_disk = {
        disk_size_gb         = var.virtual_machine_set_specs[vm_set_name].os_disk.disk_size_gb
        storage_account_type = var.virtual_machine_set_specs[vm_set_name].os_disk.storage_account_type
      }
    } if vm_set != null
  }
}
