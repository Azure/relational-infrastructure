locals {
  # Helper function to find network key by network name
  network_key_by_name = {
    for network_ref, network in local.networks : network.name => network_ref
  }

  # Transform Key Vault private endpoints configuration
  key_vault_private_endpoints = {
    for pe_name, pe in try(var.private_endpoints.key_vaults, {}) : pe_name => {
      # Find the network_ref (key) by network name
      network_ref = local.network_key_by_name[pe.network_name]
      
      name                           = coalesce(pe.name, "${var.deployment_prefix}-${pe.key_vault_name}-kv-pe")
      resource_group_name            = module.network_resource_groups[local.networks[local.network_key_by_name[pe.network_name]].location_ref].name
      location                       = var.locations[local.networks[local.network_key_by_name[pe.network_name]].location_ref]
      subnet_resource_id             = module.networks.virtual_networks[local.network_key_by_name[pe.network_name]].subnets["${local.network_key_by_name[pe.network_name]}-${pe.subnet_name}"].resource_id
      private_connection_resource_id = module.key_vaults[pe.key_vault_name].resource_id
      private_service_connection_name = "${var.deployment_prefix}-${pe.key_vault_name}-kv-psc"
      subresource_names              = ["vault"]
      network_interface_name         = "${var.deployment_prefix}-${pe.key_vault_name}-kv-nic"
      
      # IP configurations if a specific IP is required
      ip_configurations = pe.private_ip != null ? {
        primary = {
          name               = "primary"
          private_ip_address = pe.private_ip
          subresource_name   = "vault"
          member_name        = "default"
        }
      } : {}
      
      # DNS zone configuration
      private_dns_zone_group_name   = try(pe.dns_zone_group.name, "default")
      private_dns_zone_resource_ids = try(pe.dns_zone_group.private_dns_zone_ids, [])
      
      # Tags
      tags = merge(var.global_tags, (var.include_label_tags ? { keyvault_label = pe.key_vault_name } : {}))
    }
  }
  
  # Transform Storage Account private endpoints configuration
  # Note: This requires implementing storage accounts module separately
  storage_account_private_endpoints = {
    for pe_name, pe in try(var.private_endpoints.storage_accounts, {}) : pe_name => {
      # Find the network_ref (key) by network name
      network_ref = local.network_key_by_name[pe.network_name]
      
      name                           = coalesce(pe.name, "${var.deployment_prefix}-${pe.storage_account_name}-${pe.subresource_name}-pe")
      resource_group_name            = module.network_resource_groups[local.networks[local.network_key_by_name[pe.network_name]].location_ref].name
      location                       = var.locations[local.networks[local.network_key_by_name[pe.network_name]].location_ref]
      subnet_resource_id             = module.networks.virtual_networks[local.network_key_by_name[pe.network_name]].subnets["${local.network_key_by_name[pe.network_name]}-${pe.subnet_name}"].resource_id
      # This requires implementing a storage accounts module and referencing its output
      # Uncomment and update this once storage accounts are implemented
      # private_connection_resource_id = module.storage_accounts[pe.storage_account_name].resource_id
      private_connection_resource_id = "/subscriptions/placeholder-subscription-id/resourceGroups/placeholder-rg/providers/Microsoft.Storage/storageAccounts/placeholder"
      private_service_connection_name = "${var.deployment_prefix}-${pe.storage_account_name}-${pe.subresource_name}-psc"
      subresource_names              = [pe.subresource_name]
      network_interface_name         = "${var.deployment_prefix}-${pe.storage_account_name}-${pe.subresource_name}-nic"
      
      # IP configurations if a specific IP is required
      ip_configurations = pe.private_ip != null ? {
        primary = {
          name               = "primary"
          private_ip_address = pe.private_ip
          subresource_name   = pe.subresource_name
          member_name        = "default"
        }
      } : {}
      
      # DNS zone configuration
      private_dns_zone_group_name   = try(pe.dns_zone_group.name, "default")
      private_dns_zone_resource_ids = try(pe.dns_zone_group.private_dns_zone_ids, [])
      
      # Tags
      tags = merge(var.global_tags, (var.include_label_tags ? { storage_account_label = pe.storage_account_name } : {}))
    }
  }
  
  # Only include key vault private endpoints for now
  # Uncomment storage account endpoints once storage account module is implemented
  all_private_endpoints = local.key_vault_private_endpoints
  # all_private_endpoints = merge(
  #   local.key_vault_private_endpoints,
  #   local.storage_account_private_endpoints
  # )
}