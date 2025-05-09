locals {
  # We only use [default_location] in places that are theoretically inconsequential, 
  # like resource group locations.

  default_location = values(var.locations)[0]

  private_link_resource_group_name = coalesce(
    var.private_link_resource_group_name,
    var.default_resource_group_name
  )

  networks = {
    for network_ref, network in var.networks : network_ref => {
      address_space          = network.address_space
      dns_ips                = network.dns_ip_addresses
      enable_ddos_protection = network.enable_ddos_protection
      location_name          = network.location_name
      resource_group_name    = network.resource_group_name
      name                   = local.network_names[network_ref]
      tags                   = network.tags
      lock                   = local.network_locks[network_ref]

      subnets = {
        for subnet_ref, subnet in network.subnets : subnet_ref => {
          address_space       = subnet.address_space
          name                = lower(coalesce(subnet.name, subnet_ref))
          security_group_name = subnet.security_group_name
          security_rules      = subnet.security_rules
          route_table_name    = subnet.route_table_name
          routes              = subnet.route_traffic
        }
      }
    } if network != null
  }

  network_address_spaces = {
    for network_name, network in merge(var.networks, var.external_networks)
    : network_name => {
      address_space = network.address_space

      subnets = {
        for subnet_name, subnet in network.subnets
        : subnet_name => {
          address_space = subnet.address_space
        }
      }
    } if network != null
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
}
