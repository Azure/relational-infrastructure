locals {

  virtual_machine_scale_sets = merge(
    # Auto-generated scale sets for VM sets without an explicit scale_set_name
    {
      for vm_set_name, vm_set in var.virtual_machine_sets :
      vm_set_name => {
        location_name                     = vm_set.location_name
        resource_group_name               = vm_set.resource_group_name
        name                              = null
        tags                              = {}
        include_deployment_prefix_in_name = vm_set.include_deployment_prefix_in_name
      } if vm_set.scale_set_name == null
    },
    # Explicitly defined scale sets win over auto-generated ones
    var.virtual_machine_scale_sets,
  )

  virtual_machine_set_scale_set_keys = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => coalesce(vm_set.scale_set_name, vm_set_name)
  }

  data_disk_configs = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => {
      for disk in flatten([
        for disk_group_name, disk_group in vm_set.data_disk_groups : [
          for disk_index in range(var.virtual_machine_set_specs[vm_set_name].data_disk_groups[disk_group_name].disk_count) : {
            disk_index                   = disk_index
            vm_set_name                  = vm_set_name
            disk_group_name              = disk_group_name
            caching                      = disk_group.caching
            image                        = disk_group.image
            enable_public_network_access = disk_group.enable_public_network_access
            disk_encryption_set_id       = disk_group.disk_encryption_set_id
            lock_groups                  = disk_group.lock_groups
            disk_iops_read_only          = var.virtual_machine_set_specs[vm_set_name].data_disk_groups[disk_group_name].disk_iops_read_only
            disk_iops_read_write         = var.virtual_machine_set_specs[vm_set_name].data_disk_groups[disk_group_name].disk_iops_read_write
            disk_size_gb                 = var.virtual_machine_set_specs[vm_set_name].data_disk_groups[disk_group_name].disk_size_gb
            storage_account_type         = var.virtual_machine_set_specs[vm_set_name].data_disk_groups[disk_group_name].storage_account_type

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

  maintenance_schedule_recurrence = {
    for schedule_name, schedule in var.maintenance_schedules :
    schedule_name => (
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
    for schedule_name, schedule in var.maintenance_schedules :
    schedule_name => {
      duration        = schedule.duration
      recur_every     = local.maintenance_schedule_recurrence[schedule_name]
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
      schedule            = local.maintenance_schedules[vm_set.maintenance.schedule_name]
      scope               = "InGuestPatch"
      location_name       = vm_set.location_name
      resource_group_name = vm_set.resource_group_name
      schedule_name       = vm_set.maintenance.schedule_name
      vm_set_name         = vm_set_name
    } if try(vm_set.maintenance.schedule_name, null) != null
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
    } if try(vm_set.shutdown_schedule_name, null) != null
  }
}
