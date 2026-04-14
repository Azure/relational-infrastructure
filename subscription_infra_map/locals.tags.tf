locals {
  network_tags = {
    for network_name, network in local.networks :
    network_name => merge(
      var.tags,
      network.tags,
      var.include_label_tags ? {
        "network_label"        = network_name,
        "location_label"       = network.location_name,
        "resource_group_label" = network.resource_group_name
      } : {}
    )
  }

  # security_group_tags = {
  #   for group_name, group in local.network_security_groups_to_provision :
  #   group_name => merge(
  #     var.tags,
  #     group.tags,
  #     var.include_label_tags ? {
  #       "location_label"       = group.location_ref,
  #       "network_label"        = group.network_ref,
  #       "resource_group_label" = group.resource_group_name,
  #       "subnet_label"         = group.subnet_ref
  #     } : {}
  #   )
  # }

  storage_account_tags = {
    for account_name, account in var.storage_accounts :
    account_name => merge(
      var.tags,
      account.tags,
      var.include_label_tags ? {
        "location_label"        = account.location_name,
        "resource_group_label"  = account.resource_group_name,
        "storage_account_label" = account_name
      } : {}
    )
  }

  route_table_tags = {
    for table_name, table in local.route_tables :
    table_name => merge(
      var.tags,
      table.tags,
      var.include_label_tags ? {
        "location_label"       = table.location_ref,
        "network_label"        = table.network_ref,
        "resource_group_label" = table.resource_group_name,
        "subnet_label"         = table.subnet_ref
      } : {}
    )
  }

  resource_group_tags = {
    for group_name, group in var.resource_groups :
    group_name => merge(
      var.tags,
      group.tags,
      var.include_label_tags ? {
        "location_label"       = group.location_name
        "resource_group_label" = group_name
      } : {}
    )
  }

  key_vault_tags = {
    for key_vault_name, key_vault in var.key_vaults :
    key_vault_name => merge(
      var.tags,
      key_vault.tags,
      var.include_label_tags ? {
        "key_vault_label"      = key_vault_name
        "location_label"       = key_vault.location_name
        "resource_group_label" = key_vault.resource_group_name
      } : {}
    )
  }

  key_vault_private_endpoint_tags = {
    for endpoint_name, endpoint in var.private_endpoints.key_vaults :
    endpoint_name => merge(
      var.tags,
      var.include_label_tags ? {
        "key_vault_label"      = endpoint.key_vault_name
        "network_label"        = endpoint.network_name
        "subnet_label"         = endpoint.subnet_name
        "resource_group_label" = endpoint.resource_group_name
      } : {}
    )
  }

  blob_container_private_endpoint_tags = {
    for pe_name, pe in var.private_endpoints.blob_containers :
    pe_name => merge(
      var.tags,
      var.include_label_tags ? {
        "container_label"       = pe.container_name
        "storage_account_label" = var.blob_containers[pe.container_name].storage_account_name
        "location_label"        = var.storage_accounts[var.blob_containers[pe.container_name].storage_account_name].location_name
        "network_label"         = pe.network_name
        "subnet_label"          = pe.subnet_name
        "resource_group_label"  = pe.resource_group_name
      } : {}
    )
  }

  file_share_private_endpoint_tags = {
    for pe_name, pe in var.private_endpoints.file_shares :
    pe_name => merge(
      var.tags,
      var.include_label_tags ? {
        "share_label"           = pe.share_name
        "storage_account_label" = var.file_shares[pe.share_name].storage_account_name
        "location_label"        = var.storage_accounts[var.file_shares[pe.share_name].storage_account_name].location_name
        "network_label"         = pe.network_name
        "subnet_label"          = pe.subnet_name
        "resource_group_label"  = pe.resource_group_name
      } : {}
    )
  }

  private_endpoint_tags = merge(
    local.key_vault_private_endpoint_tags,
    local.blob_container_private_endpoint_tags,
    local.file_share_private_endpoint_tags
  )

  virtual_machine_set_tags = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => merge(
      var.tags,
      vm_set.tags,
      var.include_label_tags && try(vm_set.maintenance.schedule_name, null) != null ? {
        "maintenance_schedule_label" = vm_set.maintenance.schedule_name
      } : {},
      var.include_label_tags && try(vm_set.shutdown_schedule_name, null) != null ? {
        "shutdown_schedule_label" = vm_set.shutdown_schedule_name
      } : {},
      var.include_label_tags ? {
        "image_label"          = vm_set.image_name
        "key_vault_label"      = vm_set.key_vault_name
        "location_label"       = vm_set.location_name
        "resource_group_label" = vm_set.resource_group_name
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
        "location_label"       = vm_set.location_name
        "resource_group_label" = vm_set.resource_group_name
        "vm_set_label"         = vm_set_name
      } : {}
    )
  }

  virtual_machine_scale_set_tags = {
    for scale_set_name, scale_set in local.virtual_machine_scale_sets :
    scale_set_name => merge(
      var.tags,
      scale_set.tags,
      var.include_label_tags ? {
        "location_label"       = scale_set.location_name
        "resource_group_label" = scale_set.resource_group_name
        "vm_scale_set_label"   = scale_set_name
      } : {}
    )
  }

  maintenance_configuration_tags = {
    for config_name, config in local.vm_set_maintenance_configurations :
    config_name => merge(
      var.tags,
      var.include_label_tags ? {
        "location_label"             = config.location_name
        "resource_group_label"       = config.resource_group_name
        "vm_set_label"               = config.vm_set_name
        "maintenance_schedule_label" = config.schedule_name
      } : {}
    )
  }
}
