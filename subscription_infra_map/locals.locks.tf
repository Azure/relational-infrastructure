locals {
  lock_modes = {
    no_delete = "CanNotDelete"
    read_only = "ReadOnly"
  }

  avm_convention_locks = {
    no_delete = {
      kind = local.lock_modes.no_delete
    }

    read_only = {
      kind = local.lock_modes.read_only
    }
  }

  unlocked_groups = {
    for group_name, group in var.lock_groups : group_name => {
      locked    = group.locked
      read_only = group.read_only
    } if !group.locked
  }

  key_vault_locked = {
    for vault_name, key_vault in var.key_vaults :
    vault_name => (
      (length(key_vault.lock_groups) > 0) &&
      (anytrue([
        for group in key_vault.lock_groups :
        group if !contains(keys(local.unlocked_groups), group)
      ]))
    )
  }

  network_locked = {
    for network_key, network in var.networks :
    network_key => (
      (length(network.lock_groups) > 0) &&
      (anytrue([
        for group in network.lock_groups :
        group if !contains(keys(local.unlocked_groups), group)
      ]))
    )
  }

  private_endpoint_locked = {
    for pe_name, pe in merge(
      var.private_endpoints.key_vaults,
      var.private_endpoints.blob_containers,
      var.private_endpoints.file_shares
    ) :
    pe_name => (
      (length(pe.lock_groups) > 0) &&
      (anytrue([
        for group in pe.lock_groups :
        group if !contains(keys(local.unlocked_groups), group)
      ]))
    )
  }

  resource_group_locked = {
    for resource_group_key, resource_group in var.resource_groups :
    resource_group_key => (
      (length(resource_group.lock_groups) > 0) &&
      (anytrue([
        for lock_group in resource_group.lock_groups :
        lock_group if !contains(keys(local.unlocked_groups), lock_group)
      ]))
    )
  }

  storage_account_locked = {
    for account_name, account in var.storage_accounts :
    account_name => (
      (length(account.lock_groups) > 0) &&
      (anytrue([
        for group in account.lock_groups :
        group if !contains(keys(local.unlocked_groups), group)
      ]))
    )
  }

  # disk_locked = {
  #   for vm_set_name, vm_set in var.virtual_machine_sets :
  #   vm_set_name => {
  #     for disk_name, disk in vm_set.data_disks :
  #     disk_name => (
  #       (length(disk.lock_groups) > 0) &&
  #       (anytrue([
  #         for group in disk.lock_groups :
  #         group if !contains(keys(local.unlocked_groups), group)
  #       ]))
  #     )
  #   }
  # }

  network_interface_locked = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => {
      for nic_name, nic in vm_set.network_interfaces :
      nic_name => (
        (length(nic.lock_groups) > 0) &&
        (anytrue([
          for group in nic.lock_groups :
          group if !contains(keys(local.unlocked_groups), group)
        ]))
      )
    }
  }

  virtual_machine_set_locked = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => (
      (length(vm_set.lock_groups) > 0) &&
      (anytrue([
        for group in vm_set.lock_groups :
        group if !contains(keys(local.unlocked_groups), group)
      ]))
    )
  }

  key_vault_locks = {
    for vault_name, key_vault in var.key_vaults :
    vault_name => (
      local.key_vault_locked[vault_name]
      ? (
        anytrue(([
          for group_name in key_vault.lock_groups :
          var.lock_groups[group_name].read_only
        ]))
        ? local.avm_convention_locks.read_only
        : local.avm_convention_locks.no_delete
      )
      : null
    )
  }

  network_locks = {
    for network_key, network in var.networks :
    network_key => (
      local.network_locked[network_key]
      ? (
        anytrue(([
          for group_name in network.lock_groups :
          var.lock_groups[group_name].read_only
        ]))
        ? local.avm_convention_locks.read_only
        : local.avm_convention_locks.no_delete
      )
      : null
    )
  }

  private_endpoint_locks = {
    for pe_name, pe in merge(
      var.private_endpoints.key_vaults,
      var.private_endpoints.blob_containers,
      var.private_endpoints.file_shares
    ) :
    pe_name => (
      local.private_endpoint_locked[pe_name]
      ? (
        anytrue(([
          for group_name in pe.lock_groups :
          var.lock_groups[group_name].read_only
        ]))
        ? local.avm_convention_locks.read_only
        : local.avm_convention_locks.no_delete
      )
      : null
    )
  }

  resource_group_locks = {
    for resource_group_key, resource_group in var.resource_groups :
    resource_group_key => (
      local.resource_group_locked[resource_group_key]
      ? (
        anytrue(([
          for lock_group_name in resource_group.lock_groups :
          var.lock_groups[lock_group_name].read_only
        ]))
        ? local.avm_convention_locks.read_only
        : local.avm_convention_locks.no_delete
      )
      : null
    )
  }

  storage_account_locks = {
    for account_name, account in var.storage_accounts :
    account_name => (
      local.storage_account_locked[account_name]
      ? (
        anytrue(([
          for group_name in account.lock_groups :
          var.lock_groups[group_name].read_only
        ]))
        ? local.avm_convention_locks.read_only
        : local.avm_convention_locks.no_delete
      )
      : null
    )
  }

  # disk_locks = {
  #   for vm_set_name, vm_set in var.virtual_machine_sets :
  #   vm_set_name => {
  #     for disk_name, disk in vm_set.data_disks :
  #     disk_name => (
  #       (
  #         local.virtual_machine_set_locked[vm_set_name] ||
  #         local.disk_locked[vm_set_name][disk_name]
  #       )
  #       ? (
  #         anytrue(([
  #           for group_name in disk.lock_groups :
  #           var.lock_groups[group_name].read_only
  #         ]))
  #         ? "read_only"
  #         : "no_delete"
  #       )
  #       : null
  #     )
  #   }
  # }

  network_interface_locks = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => {
      for nic_name, nic in vm_set.network_interfaces :
      nic_name => (
        (
          local.virtual_machine_set_locked[vm_set_name] ||
          local.network_interface_locked[vm_set_name][nic_name]
        )
        ? (
          anytrue(([
            for group_name in nic.lock_groups :
            var.lock_groups[group_name].read_only
          ]))
          ? "read_only"
          : "no_delete"
        )
        : null
      )
    }
  }

  virtual_machine_set_locks = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => (
      local.virtual_machine_set_locked[vm_set_name]
      ? (
        anytrue(([
          for group_name in vm_set.lock_groups :
          var.lock_groups[group_name].read_only
        ]))
        ? "read_only"
        : "no_delete"
      )
      : null
    )
  }
}
