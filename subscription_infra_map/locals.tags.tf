locals {
  network_tags = {
    for network_name, network in local.networks :
    network_name => merge(
      var.tags,
      network.tags,
      var.include_label_tags ? {
        "network_label"        = network_name,
        "location_label"       = network.location_ref,
        "resource_group_label" = network.resource_group_name
      } : {}
    )
  }

  security_group_tags = {
    for group_name, group in local.network_security_groups :
    group_name => merge(
      var.tags,
      group.tags,
      var.include_label_tags ? {
        "location_label"       = group.location_ref,
        "network_label"        = group.network_ref,
        "resource_group_label" = group.resource_group_name,
        "subnet_label"         = group.subnet_ref
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
      endpoint.tags,
      var.include_label_tags ? {
        "key_vault_label"      = endpoint.key_vault_name
        "location_label"       = endpoint.location_name
        "network_label"        = endpoint.network_name
        "subnet_label"         = endpoint.subnet_name
        "resource_group_label" = endpoint.resource_group_name
      } : {}
    )
  }

  storage_account_private_endpoint_tags = {
    for endpoint_name, endpoint in var.private_endpoints.storage_accounts :
    endpoint_name => merge(
      var.tags,
      endpoint.tags,
      var.include_label_tags ? {
        "storage_account_label" = endpoint.storage_account_name
        "location_label"        = endpoint.location_name
        "network_label"         = endpoint.network_name
        "subnet_label"          = endpoint.subnet_name
        "resource_group_label"  = endpoint.resource_group_name
      } : {}
    )
  }

  private_endpoint_tags = merge(
    local.key_vault_private_endpoint_tags,
    local.storage_account_private_endpoint_tags
  )

  virtual_machine_set_tags = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => merge(
      var.tags,
      vm_set.tags,
      var.include_label_tags ? {
        "key_vault_label"      = vm_set.key_vault_name
        "location_label"       = vm_set.location_name
        "resource_group_label" = vm_set.resource_group_name
        "vm_set_label"         = vm_set_name
      } : {}
    )
  }
}
