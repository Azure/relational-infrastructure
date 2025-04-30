module "resource_groups" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  for_each = var.resource_groups

  location = (
    each.value.location_name == null
    ? values(var.locations)[0]
    : var.locations[each.value.location_name]
  )

  name = local.resource_group_names[each.key]

  lock = (
    length([
      for group in each.value.lock_groups :
      # Apply a lock only if lock_groups specifies a locked group
      group if contains(keys(local.locked_groups), group)
    ]) > 0
    ? (
      anytrue([
        for group in each.value.lock_groups :
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

  tags = local.resource_group_tags[each.key]
}

module "ddos_protection_plan" {
  source = "Azure/avm-res-network-ddosprotectionplan/azurerm"
  count  = anytrue(values(var.networks)[*].enable_ddos_protection) ? 1 : 0

  location            = values(var.locations)[0]
  name                = "${var.deployment_prefix}-ddosplan"
  resource_group_name = module.resource_groups[var.default_resource_group_name].name
}

data "azurerm_client_config" "current" {}

module "naming" {
  source = "Azure/naming/azurerm"
}

module "storage_accounts" {
  source   = "Azure/avm-res-storage-storageaccount/azurerm"
  for_each = var.storage_accounts

  location                   = var.locations[each.value.location_name]
  name                       = local.storage_account_names[each.key]
  resource_group_name        = module.resource_groups[each.value.resource_group_name].name
  tags                       = local.storage_account_tags[each.key]
  access_tier                = each.value.access_tier
  account_tier               = each.value.account_tier
  account_kind               = each.value.account_type
  account_replication_type   = each.value.replication_type
  https_traffic_only_enabled = !(each.value.allow_http_access)

  lock = (
    length([
      for group in each.value.lock_groups :
      # Apply a lock only if lock_groups specifies a locked group
      group if contains(keys(local.locked_groups), group)
    ]) > 0
    ? (
      anytrue([
        for group in each.value.lock_groups :
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

  containers = {
    for container_name, container in var.blob_containers :
    container_name => {
      name = container.name

      public_access = (
        container.enable_public_network_access
        ? "Blob" : "None"
      )
    } if container.storage_account_name == each.key
  }

  shares = {
    for share_name, share in var.file_shares :
    share_name => {
      name             = share.name
      quota            = share.quota_gb
      access_tier      = share.access_tier
      enabled_protocol = share.protocol
    } if share.storage_account_name == each.key
  }
}

#Create the Keyvaults
module "key_vaults" {
  source = "Azure/avm-res-keyvault-vault/azurerm"
  # version = "0.10.0"
  for_each = { for name, kv in var.key_vaults : name => kv if kv != null }

  location            = var.locations[each.value.location_name]
  resource_group_name = module.resource_groups[each.value.resource_group_name].name

  name = local.key_vault_names[each.key]

  lock = (
    length([
      for group in each.value.lock_groups :
      # Apply a lock only if lock_groups specifies a locked group
      group if contains(keys(local.locked_groups), group)
    ]) > 0
    ? (
      anytrue([
        for group in each.value.lock_groups :
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

  tenant_id                       = coalesce(each.value.tenant_id, data.azurerm_client_config.current.tenant_id)
  sku_name                        = each.value.sku_name
  enabled_for_deployment          = each.value.enabled_for_deployment
  enabled_for_disk_encryption     = each.value.enabled_for_disk_encryption
  enabled_for_template_deployment = each.value.enabled_for_template_deployment
  purge_protection_enabled        = each.value.purge_protection_enabled
  public_network_access_enabled   = each.value.public_network_access_enabled
  soft_delete_retention_days      = each.value.soft_delete_retention_days

  #Wait for RBAC Operations
  wait_for_rbac_before_key_operations     = each.value.wait_for_rbac_before_key_operations
  wait_for_rbac_before_secret_operations  = each.value.wait_for_rbac_before_secret_operations
  wait_for_rbac_before_contact_operations = each.value.wait_for_rbac_before_contact_operations

  #Role Assignments
  role_assignments = merge(
    each.value.role_assignments,
    {
      current_user_admin = {
        role_definition_id_or_name = "Key Vault Administrator"
        principal_id               = "${data.azurerm_client_config.current.object_id}"
      }
    }
  )

  #Network ACLs
  network_acls = each.value.network_acls != null ? {
    bypass         = each.value.network_acls.bypass
    default_action = each.value.network_acls.default_action
    ip_rules       = each.value.network_acls.ip_rules
    # virtual_network_subnet_ids = flatten([
    #   for subnet_ref in each.value.network_acls.virtual_network_subnet_ids : 
    #   (startswith(subnet_ref, "/") ? 
    #     subnet_ref : 
    #     contains(split(":", subnet_ref), ":") ? 
    #       module.networks.virtual_networks[split(":", subnet_ref)[0]].subnets["${split(":", subnet_ref)[0]}-${split(":", subnet_ref)[1]}"].resource_id :
    #       subnet_ref)
    # ])
  } : null

  #Legacy Access Policies
  #Private Endpoints
  #Diagnostic Settings

  tags = local.key_vault_tags[each.key]
}


# Creating the Private DNS Zone for all Key Vault
resource "azurerm_private_dns_zone" "keyvault_dns_zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = module.resource_groups[local.private_link_resource_group_name].name
  tags                = merge(var.tags, { service = "dns" })
}

resource "azurerm_private_dns_zone" "blob_storage_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = module.resource_groups[local.private_link_resource_group_name].name
  tags                = merge(var.tags, { service = "dns" })
}

resource "azurerm_private_dns_zone" "file_share_dns_zone" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = module.resource_groups[local.private_link_resource_group_name].name
  tags                = merge(var.tags, { service = "dns" })
}

# Create Virtual Network Links for all networks that need to resolve the private endpoint
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_vnet_links" {
  for_each = local.networks

  name                  = local.key_vault_private_link_names[each.key]
  resource_group_name   = module.resource_groups[local.private_link_resource_group_name].name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_dns_zone.name
  virtual_network_id    = module.networks[each.key].resource_id
  registration_enabled  = false
  tags                  = merge(var.tags, { network_name = each.value.name })
}

# Private Endpoints for Azure services
module "private_endpoints" {
  source   = "Azure/avm-res-network-privateendpoint/azurerm"
  for_each = local.all_private_endpoints

  name                           = local.all_private_endpoint_names[each.key]
  resource_group_name            = module.resource_groups[each.value.resource_group_name].name
  location                       = each.value.location
  subnet_resource_id             = each.value.subnet_resource_id
  private_connection_resource_id = each.value.private_connection_resource_id
  network_interface_name         = each.value.network_interface_name

  # IP configurations if specified
  ip_configurations = each.value.ip_configurations

  # Subresource names
  subresource_names = each.value.subresource_names

  private_dns_zone_group_name   = each.value.private_dns_zone_group_name
  # DNS configuration
  private_dns_zone_resource_ids = each.value.private_dns_zone_resource_ids

  # Service connection name
  private_service_connection_name = each.value.private_service_connection_name

  # Tags
  #tags = each.value.tags
  tags = local.private_endpoint_tags[each.key]
}

module "networks" {
  source   = "Azure/avm-res-network-virtualnetwork/azurerm"
  for_each = local.networks

  name                = each.value.name
  location            = var.locations[each.value.location_name]
  address_space       = [each.value.address_space]
  resource_group_name = module.resource_groups[each.value.resource_group_name].name
  tags                = local.network_tags[each.key]

  ddos_protection_plan = (
    each.value.enable_ddos_protection
    ? {
      id     = module.ddos_protection_plan[0].resource_id
      enable = true
    }
    : null
  )

  lock = each.value.lock

  dns_servers = { # What?
    dns_servers = (each.value.dns_ips == null ? null : each.value.dns_ips)
  }

  subnets = {
    for subnet_name, subnet in each.value.subnets :
    subnet_name => {
      name             = coalesce(subnet.name, subnet_name)
      address_prefixes = [subnet.address_space]

      network_security_group = (
        contains(keys(local.network_security_groups), "${each.key}_${subnet_name}")
        ? { id = module.network_security_groups["${each.key}_${subnet_name}"].resource_id }
        : null
      )

      route_table = (
        contains(keys(local.route_tables), "${each.key}_${subnet_name}")
        ? { id = module.route_tables["${each.key}_${subnet_name}"].resource_id }
        : null
      )
    }
  }
}

module "route_tables" {
  source   = "Azure/avm-res-network-routetable/azurerm"
  for_each = local.route_tables

  location            = var.locations[each.value.location_ref]
  name                = local.route_table_names[each.value.network_ref][each.value.subnet_ref]
  resource_group_name = module.resource_groups[each.value.resource_group_name].name
  lock                = each.value.lock
  tags                = local.network_tags[each.value.network_ref]

  routes = {
    for route_ref, route in each.value.routes : route_ref => {
      name                   = route.route_name
      address_prefix         = route.address_prefix
      next_hop_type          = route.next_hop_type
      next_hop_in_ip_address = route.next_hop_ip_address
    }
  }
}

resource "azurerm_monitor_activity_log_alert" "route_table_activity_log_alerts" {
  for_each = local.route_tables

  name                = "${local.route_table_names[each.value.network_ref][each.value.subnet_ref]}-changed-alert"
  resource_group_name = module.resource_groups[each.value.resource_group_name].name
  location            = "global"
  scopes              = [module.route_tables[each.key].resource_id]
  tags                = local.network_tags[each.value.network_ref]
  description         = "This alert will monitor route table [${local.route_table_names[each.value.network_ref][each.value.subnet_ref]}] for any changes."

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/routeTables/write"
    resource_id    = module.route_tables[each.key].resource_id
  }
}

module "network_security_groups" {
  source   = "Azure/avm-res-network-networksecuritygroup/azurerm"
  for_each = local.network_security_groups

  location            = var.locations[each.value.location_ref]
  name                = local.security_group_names[each.value.network_ref][each.value.subnet_ref]
  resource_group_name = module.resource_groups[each.value.resource_group_name].name
  lock                = each.value.lock
  tags                = local.security_group_tags["${each.value.network_ref}_${each.value.subnet_ref}"]

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

resource "azurerm_monitor_activity_log_alert" "network_security_group_activity_log_alerts" {
  for_each = local.network_security_groups

  name                = "${local.security_group_names[each.value.network_ref][each.value.subnet_ref]}-changed-alert"
  resource_group_name = module.resource_groups[each.value.resource_group_name].name
  location            = "global"
  scopes              = [module.network_security_groups[each.key].resource_id]
  tags                = local.security_group_tags["${each.value.network_ref}_${each.value.subnet_ref}"]
  description         = "This alert will monitor network security group [${local.security_group_names[each.value.network_ref][each.value.subnet_ref]}] for any changes."

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/networkSecurityGroups/write"
    resource_id    = module.network_security_groups[each.key].resource_id
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

module "virtual_machine_sets" {
  source   = "../infra_map_vm_set"
  for_each = { for name, vm_set in var.virtual_machine_sets : name => vm_set if vm_set != null }

  location                                      = var.locations[each.value.location_name]
  resource_group_name                           = module.resource_groups[each.value.resource_group_name].name
  resource_group_id                             = module.resource_groups[each.value.resource_group_name].resource_id
  resource_prefix                               = "${var.deployment_prefix}${coalesce(each.value.name, each.key)}"
  resource_tags                                 = local.virtual_machine_set_tags[each.key]
  virtual_machine_count                         = var.virtual_machine_set_specs[each.key].vm_count
  deploy_scale_set                              = each.value.deploy_scale_set
  enable_automatic_updates                      = var.enable_automatic_updates
  enable_virtual_machine_boot_diagnostics       = each.value.enable_boot_diagnostics
  virtual_machine_capacity_reservation_group_id = each.value.capacity_reservation_group_id
  virtual_machine_disk_controller_type          = each.value.disk_controller_type
  virtual_machine_image                         = var.virtual_machine_images[each.value.image_name]
  virtual_machine_os_type                       = each.value.os_type
  virtual_machine_sku_size                      = var.virtual_machine_set_specs[each.key].sku_size
  virtual_machine_zone_distribution             = coalesce(try(var.virtual_machine_set_zone_distribution[each.key], null), { custom = null, even = ["1", "2", "3"] })
  #                                               By default, unless overridden by [var.virtual_machine_set_zone_distribution], 
  #                                               zone distribution is always even across all 3 zones.

  maintenance_configuration = (
    try(each.value.maintenance.schedule_name, null) == null ? null
    : local.vm_set_maintenance_configurations[each.key]
  )

  lock_mode = (
    length([
      for group in each.value.lock_groups :
      # Apply a lock only if lock_groups specifies a locked group
      group if contains(keys(local.locked_groups), group)
    ]) > 0
    ? (
      anytrue([
        for group in each.value.lock_groups :
        # Apply a lock only if the group is locked
        # Read-only is the most restrictive lock. If any group is read-only, apply it.
        # Otherwise, apply a no-delete lock.
        contains(keys(local.locked_groups), group)
        && try(local.locked_groups[group].read_only, false)
      ])
      ? "read_only"
      : "no_delete"
    )
    : null
  )

  # Pass the Key Vault resource ID for secret storage
  # Use primary key vault for primary location VMs, and alt key vault for alt location VMs
  generated_secrets_key_vault_secret_config = {
    key_vault_resource_id          = module.key_vaults[each.value.key_vault_name].resource_id
    name                           = "vm-${replace(each.key, "/[^a-zA-Z0-9-]/", "")}-creds"
    expiration_date_length_in_days = 90
    content_type                   = "password"
    tags                           = merge(var.tags, each.value.tags, { credential_type = "generated" })
  }

  virtual_machine_extensions = {
    for extension_name in concat(var.extensions, each.value.extensions) :
    extension_name => var.virtual_machine_extensions[extension_name]
  }

  virtual_machine_data_disks = {
    for disk_name, disk in each.value.data_disks : disk_name => {
      caching                      = disk.caching
      image                        = disk.image
      lun                          = disk.lun
      disk_size_gb                 = var.virtual_machine_set_specs[each.key].data_disks[disk_name].disk_size_gb
      storage_account_type         = var.virtual_machine_set_specs[each.key].data_disks[disk_name].storage_account_type
      enable_public_network_access = disk.enable_public_network_access

      lock_mode = (
        length([
          for group in disk.lock_groups :
          # Apply a lock only if lock_groups specifies a locked group
          group if contains(keys(local.locked_groups), group)
        ]) > 0
        ? (
          anytrue([
            for group in disk.lock_groups :
            # Apply a lock only if the group is locked
            # Read-only is the most restrictive lock. If any group is read-only, apply it.
            # Otherwise, apply a no-delete lock.
            contains(keys(local.locked_groups), group)
            && try(local.locked_groups[group].read_only, false)
          ])
          ? "read_only"
          : "no_delete"
        )
        : null
      )
    }
  }

  virtual_machine_network_interfaces = {
    for nic_name, nic in each.value.network_interfaces : nic_name => {
      private_ip                    = nic.private_ip
      enable_accelerated_networking = nic.enable_accelerated_networking
      subnet_id                     = module.networks[nic.network_name].subnets[nic.subnet_name].resource_id

      lock_mode = (
        length([
          for group in nic.lock_groups :
          # Apply a lock only if lock_groups specifies a locked group
          group if contains(keys(local.locked_groups), group)
        ]) > 0
        ? (
          anytrue([
            for group in nic.lock_groups :
            # Apply a lock only if the group is locked
            # Read-only is the most restrictive lock. If any group is read-only, apply it.
            # Otherwise, apply a no-delete lock.
            contains(keys(local.locked_groups), group)
            && try(local.locked_groups[group].read_only, false)
          ])
          ? "read_only"
          : "no_delete"
        )
        : null
      )
    }
  }

  virtual_machine_os_disk = {
    disk_size_gb         = var.virtual_machine_set_specs[each.key].os_disk.disk_size_gb
    storage_account_type = var.virtual_machine_set_specs[each.key].os_disk.storage_account_type
  }
}
