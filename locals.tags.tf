locals {
  network_tags = {
    for network_key, network in local.networks :
    network_key => merge(
      var.tags,
      network.tags,
      var.include_label_tags ? {
        "network_label"        = network_key,
        "location_label"       = network.location_key_reference,
        "resource_group_label" = network.resource_group_key_reference
      } : {}
    )
  }

  security_group_tags = {
    for nsg_key, nsg in local.network_security_groups :
    nsg_key => merge(
      var.tags,
      nsg.tags,
      var.include_label_tags ? {
        "location_label"       = nsg.location_key_reference,
        "resource_group_label" = nsg.resource_group_key_reference,
        "nsg_label"            = nsg_key
      } : {}
    )
  }

  storage_account_tags = {
    for account_name, account in var.storage_accounts :
    account_name => merge(
      var.tags,
      account.tags,
      var.include_label_tags ? {
        "location_label"        = account.location_key_reference,
        "resource_group_label"  = account.resource_group_key_reference,
        "storage_account_label" = account_name
      } : {}
    )
  }

  route_table_tags = {
    for table_key, table in local.route_tables :
    table_key => merge(
      var.tags,
      table.tags,
      var.include_label_tags ? {
        "location_label"       = table.location_key_reference,
        "resource_group_label" = table.resource_group_key_reference,
        "route_table_label"    = table_key
      } : {}
    )
  }

  resource_group_tags = {
    for group_name, group in var.resource_groups :
    group_name => merge(
      var.tags,
      group.tags,
      var.include_label_tags ? {
        "location_label"       = group.location_key_reference
        "resource_group_label" = group_name
      } : {}
    )
  }

  key_vault_tags = {
    for key_vault_key, key_vault in var.key_vaults :
    key_vault_key => merge(
      var.tags,
      key_vault.tags,
      var.include_label_tags ? {
        "key_vault_label"      = key_vault_key
        "location_label"       = key_vault.location_key_reference
        "resource_group_label" = key_vault.resource_group_key_reference
      } : {}
    )
  }

  virtual_machine_set_tags = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => merge(
      var.tags,
      vm_set.tags,
      var.include_label_tags && try(vm_set.maintenance.schedule_key_reference, null) != null ? {
        "maintenance_schedule_label" = vm_set.maintenance.schedule_key_reference
      } : {},
      var.include_label_tags && try(vm_set.shutdown_schedule_key, null) != null ? {
        "shutdown_schedule_label" = vm_set.shutdown_schedule_key
      } : {},
      var.include_label_tags ? {
        "image_label"          = vm_set.image_key
        "key_vault_label"      = vm_set.key_vault_key_reference
        "location_label"       = vm_set.location_key_reference
        "resource_group_label" = vm_set.resource_group_key_reference
        "vm_set_label"         = vm_set_name
      } : {}
    )
  }

  virtual_machine_set_asg_tags = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => merge(
      var.tags,
      vm_set.tags,
      var.include_label_tags ? {
        "location_label"       = vm_set.location_key_reference
        "resource_group_label" = vm_set.resource_group_key_reference
        "vm_set_label"         = vm_set_name
      } : {}
    )
  }

  maintenance_configuration_tags = {
    for config_name, config in local.vm_set_maintenance_configurations :
    config_name => merge(
      var.tags,
      var.include_label_tags ? {
        "location_label"             = config.location_key_reference
        "resource_group_label"       = config.resource_group_key_reference
        "vm_set_label"               = config.vm_set_name
        "maintenance_schedule_label" = config.schedule_key_reference
      } : {}
    )
  }
}
