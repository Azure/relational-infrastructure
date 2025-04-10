module "network_resource_groups" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  for_each = var.locations

  location = each.value
  name     = "${var.deployment_prefix}-${each.value}-networks"
  tags     = var.global_tags
}

module "ddos_protection_plan" {
  source = "Azure/avm-res-network-ddosprotectionplan/azurerm"
  count  = anytrue(values(var.networks)[*].enable_ddos_protection) ? 1 : 0

  location            = var.locations["primary"]
  name                = coalesce(var.ddos_protection_plan_name, "${var.deployment_prefix}-ddos-plan")
  resource_group_name = module.network_resource_groups["primary"].name
}

data "azurerm_client_config" "current" {}

module "naming" {
  source = "Azure/naming/azurerm"
}

# Create the Keyvaults
module "key_vaults" {
  source = "Azure/avm-res-keyvault-vault/azurerm"
  # version = "0.10.0"
  for_each = { for name, kv in var.key_vaults : name => kv if kv != null }

  location            = var.locations[each.value.location_name]
  resource_group_name = module.network_resource_groups[each.value.location_name].name

  name = coalesce(each.value.name, "${var.deployment_prefix}-${each.key}-kv")

  tenant_id                       = coalesce(each.value.tenant_id, data.azurerm_client_config.current.tenant_id)
  sku_name                        = each.value.sku_name
  enabled_for_deployment          = each.value.enabled_for_deployment
  enabled_for_disk_encryption     = each.value.enabled_for_disk_encryption
  enabled_for_template_deployment = each.value.enabled_for_template_deployment
  purge_protection_enabled        = each.value.purge_protection_enabled
  public_network_access_enabled   = each.value.public_network_access_enabled
  soft_delete_retention_days      = each.value.soft_delete_retention_days

  # Wait for RBAC Operations
  wait_for_rbac_before_key_operations     = each.value.wait_for_rbac_before_key_operations
  wait_for_rbac_before_secret_operations  = each.value.wait_for_rbac_before_secret_operations
  wait_for_rbac_before_contact_operations = each.value.wait_for_rbac_before_contact_operations

  # Role Assignments
  role_assignments = merge(
    each.value.role_assignments,
    {
      current_user_admin = {
        role_definition_id_or_name = "Key Vault Administrator"
        principal_id               = "${data.azurerm_client_config.current.object_id}"
      }
    }
  )

  # Network ACLs
  network_acls = each.value.network_acls != null ? {
    bypass         = each.value.network_acls.bypass
    default_action = each.value.network_acls.default_action
    ip_rules       = each.value.network_acls.ip_rules
    } : {
    bypass         = "None"
    default_action = "Deny" # Disable public access
    ip_rules       = []
  }

  # Legacy Access Policies
  # Private Endpoints
  # Diagnostic Settings

  tags = merge(var.global_tags, each.value.tags, (var.include_label_tags ? { keyvault_label = each.key } : {}))
}

data "azurerm_role_definition" "contributor_role" {
  name = "Contributor"
}

# Create the Storage Accounts
module "storage_accounts" {
  source = "Azure/avm-res-storage-storageaccount/azurerm"
  # version = "0.5.0"

  # Required Inputs
  for_each            = { for name, sa in var.storage_accounts : name => sa if sa != null }
  location            = var.locations[each.value.location_name]
  resource_group_name = module.network_resource_groups[each.value.location_name].name

  name = coalesce(each.value.name,
    lower(replace("${substr(var.deployment_prefix, 0, 10)}${substr(each.key, 0, 13)}", "/[^a-z0-9]/", ""))
  )

  # Optional Inputs
  access_tier                      = each.value.access_tier
  account_kind                     = each.value.account_kind
  account_replication_type         = each.value.account_replication_type
  account_tier                     = each.value.account_tier
  allow_nested_items_to_be_public  = each.value.allow_nested_items_to_be_public
  allowed_copy_scope               = each.value.allowed_copy_scope
  azure_files_authentication       = each.value.azure_files_authentication
  blob_properties                  = each.value.blob_properties
  containers                       = each.value.containers
  cross_tenant_replication_enabled = each.value.cross_tenant_replication_enabled
  custom_domain                    = each.value.custom_domain
  customer_managed_key             = each.value.customer_managed_key


  managed_identities = {
    system_assigned            = each.value.managed_identity != null ? (each.value.managed_identity.type == "SystemAssigned" || each.value.managed_identity.type == "SystemAssigned,UserAssigned") : false
    user_assigned_resource_ids = each.value.managed_identity != null ? each.value.managed_identity.identity_ids : []
  }

  #role_assignments = each.value.role_assignments
  role_assignments = merge(
    each.value.role_assignments,
    {
      current_user_admin = {
        role_definition_id_or_name       = data.azurerm_role_definition.contributor_role.name
        principal_id                     = "${data.azurerm_client_config.current.object_id}"
        skip_service_principal_aad_check = false
      }
    }
  )


  # Pass file shares to the module
  # Map file shares to the shares variable expected by the module
  shares = {
    for name, fs in var.file_shares : name => {
      name               = fs.name
      quota              = fs.quota
      access_tier        = fs.access_tier
      enabled_protocol   = fs.enabled_protocol
      metadata           = fs.metadata
      root_squash        = fs.root_squash
      signed_identifiers = fs.signed_identifiers
      role_assignments   = fs.role_assignments
      timeouts           = fs.timeouts
    } if fs.storage_account_name == each.key
  }


  tags = merge(var.global_tags, each.value.tags, (var.include_label_tags ? { storageaccount_label = each.key } : {}))
}



# Creating the Private DNS Zone for all Key Vault
resource "azurerm_private_dns_zone" "keyvault_dns_zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = module.network_resource_groups["primary"].name
  tags                = merge(var.global_tags, { service = "dns" })
}

# Create Virtual Network Links for all networks that need to resolve the private endpoint
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_vnet_links" {
  for_each = local.networks

  name                  = "${each.value.name}-link"
  resource_group_name   = module.network_resource_groups["primary"].name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_dns_zone.name
  virtual_network_id    = module.networks.virtual_networks[each.key].id
  registration_enabled  = false
  tags                  = merge(var.global_tags, { network_name = each.value.name })
}

# Private Endpoints for Azure services
module "private_endpoints" {
  source   = "Azure/avm-res-network-privateendpoint/azurerm"
  for_each = local.all_private_endpoints

  name                           = each.value.name
  resource_group_name            = each.value.resource_group_name
  location                       = each.value.location
  subnet_resource_id             = each.value.subnet_resource_id
  private_connection_resource_id = each.value.private_connection_resource_id
  network_interface_name         = each.value.network_interface_name

  # IP configurations if specified
  ip_configurations = each.value.ip_configurations

  # Subresource names
  subresource_names = each.value.subresource_names

  # DNS configuration
  private_dns_zone_group_name   = each.value.private_dns_zone_group_name
  private_dns_zone_resource_ids = each.value.private_dns_zone_resource_ids

  # Service connection name
  private_service_connection_name = each.value.private_service_connection_name

  # Tags
  tags = merge(var.global_tags, each.value.tags, (var.include_label_tags ? { private_endpoint_label = each.key } : {}))
}

module "networks" {
  source = "Azure/avm-ptn-hubnetworking/azurerm"

  hub_virtual_networks = {
    for network_name, network in local.networks : network_name => {
      name                            = network.name
      location                        = var.locations[network.location_ref]
      address_space                   = [network.address_space]
      resource_group_name             = module.network_resource_groups[network.location_ref].name
      ddos_protection_plan_id         = (network.enable_ddos_protection ? module.ddos_protection_plan[0].resource_id : null)
      dns_servers                     = (network.dns_ips == null ? null : network.dns_ips)
      tags                            = merge(var.global_tags, (var.include_label_tags ? { network_label = network_name } : {}))
      mesh_peering_enabled            = var.enable_full_network_mesh # We are explicit about the peerings that should be created
      resource_group_creation_enabled = false                        # The resource group already exists

      subnets = {
        for subnet_name, subnet in network.subnets : subnet_name => {
          name             = coalesce(subnet.name, subnet_name)
          address_prefixes = [subnet.address_space]

          network_security_group = (
            contains(keys(local.network_security_groups), "${network_name}_${subnet_name}")
            ? { id = module.network_security_groups["${network_name}_${subnet_name}"].resource_id }
            : null
          )

          route_table = (
            contains(keys(local.route_tables), "${network_name}_${subnet_name}")
            ? { id = module.route_tables["${network_name}_${subnet_name}"].resource_id }
            : null
          )
        }
      }
    }
  }
}

module "route_tables" {
  source   = "Azure/avm-res-network-routetable/azurerm"
  for_each = local.route_tables

  location            = var.locations[each.value.location_ref]
  name                = each.value.name
  resource_group_name = module.network_resource_groups[each.value.location_ref].name

  tags = merge(var.global_tags,
    (var.include_label_tags ?
      { network_label = each.value.network_ref, subnet_label = each.value.subnet_ref } :
  {}))

  routes = {
    for route_ref, route in each.value.routes : route_ref => {
      name                   = route.route_name
      address_prefix         = route.address_prefix
      next_hop_type          = route.next_hop_type
      next_hop_in_ip_address = route.next_hop_ip_address
    }
  }
}

module "network_security_groups" {
  source   = "Azure/avm-res-network-networksecuritygroup/azurerm"
  for_each = local.network_security_groups

  location            = var.locations[each.value.location_ref]
  name                = each.value.name
  resource_group_name = module.network_resource_groups[each.value.location_ref].name

  tags = merge(var.global_tags,
    (var.include_label_tags ?
      { network_label = each.value.network_ref, subnet_label = each.value.subnet_ref } :
  {}))

  security_rules = {
    for rule_ref, rule in merge(
      local.allow_inbound_network_security_rules,
      local.allow_outbound_network_security_rules,
      local.deny_inbound_network_security_rules,
      local.deny_outbound_network_security_rules) : rule_ref => {
      destination_address_prefix = rule.destination.address_space
      destination_port_range     = rule.destination.port_range
      direction                  = rule.direction
      name                       = rule.rule_name
      access                     = rule.access
      priority                   = rule.priority
      protocol                   = rule.protocol
      source_address_prefix      = rule.source.address_space
      source_port_range          = rule.source.port_range
    } if rule.security_group_ref == each.key
  }
}

# Disabled temporarily due to https://github.com/Azure/terraform-azurerm-avm-ptn-hubnetworking/issues/109.

# resource "azurerm_virtual_network_peering" "peerings" {
#  for_each = tomap({
#    for peering in flatten([
#      for from_network_name, from_network in var.networks : [
#        for to_network_name in from_network.peered_to : {
#          peer_from_network_name = from_network_name
#          peer_to_network_name   = to_network_name
#        }
#      ]
#    ]) : "peer-${peering.peer_from_network_name}-to-${peering.peer_to_network_name}" => peering
#  })
#
#  name                      = each.key
#  resource_group_name       = local.networks[each.value.peer_from_network_name].resource_group_name
#  virtual_network_name      = module.networks.virtual_networks[each.value.peer_from_network_name].name
#  remote_virtual_network_id = module.networks.virtual_networks[each.value.peer_to_network_name].id
# }

module "virtual_machine_set_resource_groups" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  for_each = { for name, vm_set in var.virtual_machine_sets : name => vm_set if vm_set != null }

  location = var.locations[each.value.location_name]
  name     = "${var.deployment_prefix}-${coalesce(each.value.resource_group_name, each.key)}"
  tags     = merge(var.global_tags, each.value.tags, (var.include_label_tags ? { vm_set_label = each.key } : {}))
}

module "virtual_machine_sets" {
  source   = "../high_availability_virtual_machine_set"
  for_each = { for name, vm_set in var.virtual_machine_sets : name => vm_set if vm_set != null }

  location                                      = var.locations[each.value.location_name]
  resource_group_name                           = module.virtual_machine_set_resource_groups[each.key].name
  resource_prefix                               = "${var.deployment_prefix}${coalesce(each.value.name, each.key)}"
  resource_tags                                 = merge(var.global_tags, each.value.tags, (var.include_label_tags ? { vm_set_label = each.key } : {}))
  virtual_machine_count                         = var.virtual_machine_set_specs[each.key].vm_count
  enable_automatic_updates                      = var.enable_automatic_updates
  enable_virtual_machine_boot_diagnostics       = each.value.enable_boot_diagnostics
  virtual_machine_capacity_reservation_group_id = each.value.capacity_reservation_group_id
  virtual_machine_disk_controller_type          = each.value.disk_controller_type
  virtual_machine_image                         = each.value.image
  virtual_machine_os_type                       = each.value.os_type
  virtual_machine_sku_size                      = var.virtual_machine_set_specs[each.key].sku_size
  virtual_machine_zone_distribution             = coalesce(try(var.virtual_machine_set_zone_distribution[each.key], null), { custom = null, even = ["1", "2", "3"] })
  # By default, unless overridden by [var.virtual_machine_set_zone_distribution], 
  # zone distribution is always even across all 3 zones.

  # Pass the Key Vault resource ID for secret storage
  # Use primary key vault for primary location VMs, and alt key vault for alt location VMs
  generated_secrets_key_vault_secret_config = {
    key_vault_resource_id          = module.key_vaults[each.value.location_name].resource_id
    name                           = "vm-${replace(each.key, "/[^a-zA-Z0-9-]/", "")}-creds"
    expiration_date_length_in_days = 90
    content_type                   = "password"
    tags                           = merge(var.global_tags, each.value.tags, { credential_type = "generated" })
  }

  virtual_machine_extensions = {
    for extension_name in concat(var.global_extensions, each.value.extensions) : extension_name => var.virtual_machine_extensions[extension_name]
  }

  virtual_machine_data_disks = {
    for disk_name, disk in each.value.data_disks : disk_name => {
      caching                      = disk.caching
      image                        = disk.image
      lun                          = disk.lun
      disk_size_gb                 = var.virtual_machine_set_specs[each.key].data_disks[disk_name].disk_size_gb
      storage_account_type         = var.virtual_machine_set_specs[each.key].data_disks[disk_name].storage_account_type
      enable_public_network_access = disk.enable_public_network_access
    }
  }

  virtual_machine_network_interfaces = {
    for nic_name, nic in each.value.network_interfaces : nic_name => {
      private_ip                    = nic.private_ip
      enable_accelerated_networking = nic.enable_accelerated_networking
      subnet_id                     = module.networks.virtual_networks[nic.network_name].subnets["${nic.network_name}-${nic.subnet_name}"].resource_id
    }
  }

  virtual_machine_os_disk = {
    disk_size_gb         = var.virtual_machine_set_specs[each.key].os_disk.disk_size_gb
    storage_account_type = var.virtual_machine_set_specs[each.key].os_disk.storage_account_type
  }
}
