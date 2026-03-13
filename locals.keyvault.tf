locals {
  # Key vaults to provision with all computed values
  key_vaults_to_provision = {
    for kv_key, kv in var.key_vaults : kv_key => {
      name                = local.key_vault_names[kv_key]
      location            = var.locations[kv.location_key_reference]
      resource_group_name = module.resource_groups[kv.resource_group_key_reference].name
      tags                = local.key_vault_tags[kv_key]

      lock = (
        length([
          for group in kv.lock_groups_key_reference :
          group if contains(keys(local.locked_groups), group)
        ]) > 0
        ? (
          anytrue([
            for group in kv.lock_groups_key_reference :
            contains(keys(local.locked_groups), group)
            && try(local.locked_groups[group].read_only, false)
          ])
          ? { kind = local.lock_modes.read_only }
          : { kind = local.lock_modes.no_delete }
        )
        : null
      )

      tenant_id                       = coalesce(kv.tenant_id, data.azurerm_client_config.current.tenant_id)
      sku_name                        = kv.sku_name
      enabled_for_deployment          = kv.enabled_for_deployment
      enabled_for_disk_encryption     = kv.enabled_for_disk_encryption
      enabled_for_template_deployment = kv.enabled_for_template_deployment
      purge_protection_enabled        = kv.purge_protection_enabled
      public_network_access_enabled   = kv.public_network_access_enabled
      soft_delete_retention_days      = kv.soft_delete_retention_days

      wait_for_rbac_before_key_operations     = kv.wait_for_rbac_before_key_operations
      wait_for_rbac_before_secret_operations  = kv.wait_for_rbac_before_secret_operations
      wait_for_rbac_before_contact_operations = kv.wait_for_rbac_before_contact_operations

      role_assignments = merge(
        kv.role_assignments,
        {
          current_user_admin = {
            role_definition_id_or_name = var.default_key_vault_admin_role_definition_id_or_name
            principal_id               = data.azurerm_client_config.current.object_id
          }
        }
      )

      network_acls = kv.network_acls != null ? {
        bypass         = kv.network_acls.bypass
        default_action = kv.network_acls.default_action
        ip_rules       = kv.network_acls.ip_rules
      } : null

      private_endpoints = local.key_vault_private_endpoints[kv_key]
    } if kv != null
  }

  # Transform Key Vault private endpoints from key references to AVM module format
  key_vault_private_endpoints = {
    for kv_key, kv in var.key_vaults : kv_key => {
      for pe_key, pe in kv.private_endpoints : pe_key => {
        name = coalesce(
          pe.name,
          pe.include_deployment_prefix_in_name
          ? "${var.deployment_prefix}-${kv_key}-kv-pe"
          : "${kv_key}-kv-pe"
        )

        subnet_resource_id = local.network_resource_ids[pe.network_key_reference].subnets[pe.subnet_key_reference].resource_id

        private_dns_zone_group_name = pe.private_dns_zone_group_name

        private_dns_zone_resource_ids = concat(
          tolist(pe.private_dns_zone_resource_ids),
          [
            for zone_key in pe.private_dns_zone_key_references :
            local.private_dns_zone_resource_ids[zone_key]
          ]
        )

        private_service_connection_name = "${coalesce(pe.name, "${kv_key}-kv-pe")}-psc"
        network_interface_name          = "${coalesce(pe.name, "${kv_key}-kv")}-nic"

        location = var.locations[kv.location_key_reference]

        resource_group_name = (
          pe.resource_group_key_reference != null
          ? module.resource_groups[pe.resource_group_key_reference].name
          : module.resource_groups[kv.resource_group_key_reference].name
        )

        role_assignments = pe.role_assignments
        tags             = pe.tags

        lock = (
          length([
            for group in pe.lock_groups_key_reference :
            group if contains(keys(local.locked_groups), group)
          ]) > 0
          ? (
            anytrue([
              for group in pe.lock_groups_key_reference :
              contains(keys(local.locked_groups), group)
              && try(local.locked_groups[group].read_only, false)
            ])
            ? { kind = local.lock_modes.read_only }
            : { kind = local.lock_modes.no_delete }
          )
          : null
        )

        ip_configurations = pe.private_ip != null ? {
          primary = {
            name               = "primary"
            private_ip_address = pe.private_ip
          }
        } : {}
      }
    }
  }
}
