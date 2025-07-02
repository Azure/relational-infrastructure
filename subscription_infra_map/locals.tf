locals {
  lock_modes = {
    no_delete = "CanNotDelete"
    read_only = "ReadOnly"
  }

  # We only use [default_location] in places that are theoretically inconsequential, 
  # like resource group locations.

  default_location = values(var.locations)[0]

  private_link_resource_group_name = coalesce(
    var.private_link_resource_group_name,
    var.default_resource_group_name
  )

  locked_groups = {
    for group_name, group in var.lock_groups : group_name => {
      locked    = group.locked
      read_only = group.read_only
    } if group.locked
  }

  internal_network_ids = {
    for network_name, network in local.networks :
    network_name => {
      resource_id = module.networks[network_name].resource_id

      subnets = {
        for subnet_name, subnet in network.subnets :
        subnet_name => {
          resource_id = module.networks[network_name].subnets[subnet_name].resource_id
        }
      }
    } if network != null
  }

  external_network_ids = {
    for network_name, network in var.external_networks :
    network_name => {
      resource_id = module.external_networks[network_name].resource_id

      subnets = {
        for subnet_name, subnet in network.subnets :
        subnet_name => {
          resource_id = lower("${trimsuffix(network.resource_id, "/")}/subnets/${coalesce(subnet.name, subnet_name)}")
        }
      }
    } if try(network.resource_id, null) != null
  }

  network_ids = merge(
    local.internal_network_ids,
    local.external_network_ids
  )

  networks = {
    for network_ref, network in var.networks : network_ref => {
      address_spaces         = coalesce(network.address_spaces, compact([network.address_space]))
      dns_ips                = network.dns_ip_addresses
      enable_ddos_protection = network.enable_ddos_protection
      location_name          = network.location_name
      resource_group_name    = network.resource_group_name
      name                   = local.network_names[network_ref]
      tags                   = network.tags

      lock = (
        length([
          for group in network.lock_groups :
          # Apply a lock only if lock_groups specifies a locked group
          group if contains(keys(local.locked_groups), group)
        ]) > 0
        ? (
          anytrue([
            for group in network.lock_groups :
            # Apply a lock only if the group is locked
            # Read-only is the most restrictive lock. If any group is read-only, apply it.
            # Otherwise, apply a no-delete lock.
            contains(keys(local.locked_groups), group)
            && try(local.locked_groups[group].read_only, false)
          ])
          ? { kind = local.lock_modes.read_only }
          : { kind = local.lock_modes.no_delete }
        )
        : null
      )

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
      address_spaces = coalesce(network.address_spaces, compact([network.address_space]))

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
