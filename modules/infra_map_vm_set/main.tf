resource "azurerm_orchestrated_virtual_machine_scale_set" "virtual_machine_scale_set" {
  count = var.deploy_scale_set ? 1 : 0

  name                        = local.virtual_machine_scale_set_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  platform_fault_domain_count = 1
  single_placement_group      = false
  tags                        = var.resource_tags
  zones                       = ["1", "2", "3"]

  identity {
    type         = "UserAssigned"
    identity_ids = var.user_assigned_identity_ids
  }
}

module "virtual_machines" {
  source   = "Azure/avm-res-compute-virtualmachine/azurerm"
  for_each = var.virtual_machines
  version  = "0.20.0" # For now; running into a problems with key vault + passwords

  name                                   = local.virtual_machine_names[each.key]
  lock                                   = local.vm_lock
  tags                                   = var.resource_tags
  location                               = var.location
  computer_name                          = local.virtual_machine_computer_names[each.key]
  extensions                             = var.virtual_machine_extensions
  boot_diagnostics                       = var.enable_virtual_machine_boot_diagnostics
  capacity_reservation_group_resource_id = var.virtual_machine_capacity_reservation_group_id
  disk_controller_type                   = var.virtual_machine_disk_controller_type
  data_disk_managed_disks                = local.virtual_machine_data_disks[each.key]
  enable_automatic_updates               = var.virtual_machine_extensions_automatic_updates_enabled
  encryption_at_host_enabled             = false
  os_disk                                = local.virtual_machine_os_disks[each.key]
  os_type                                = var.virtual_machine_os_type
  network_interfaces                     = local.virtual_machine_network_interfaces[each.key]
  shutdown_schedules                     = var.virtual_machine_shutdown_schedule
  patch_mode                             = "AutomaticByPlatform"
  patch_assessment_mode                  = "AutomaticByPlatform"
  resource_group_name                    = var.resource_group_name
  source_image_reference                 = var.virtual_machine_image.reference
  source_image_resource_id               = var.virtual_machine_image.id
  sku_size                               = var.virtual_machine_sku_size
  zone                                   = local.virtual_machine_zones[each.key]

  managed_identities = {
    system_assigned            = var.virtual_machine_system_assigned_identity_enabled
    user_assigned_resource_ids = var.user_assigned_identity_ids
  }

  virtual_machine_scale_set_resource_id = (
    var.deploy_scale_set
    ? azurerm_orchestrated_virtual_machine_scale_set.virtual_machine_scale_set[0].id
    : null
  )

  generated_secrets_key_vault_secret_config = (
    var.key_vault_configuration == null ? null
    : local.virtual_machine_secret_configs[each.key]
  )

  maintenance_configuration_resource_ids = (
    var.maintenance_configuration == null ? {}
    : { config = module.virtual_machine_maintenance_configuration[0].resource_id }
  )

  bypass_platform_safety_checks_on_user_schedule_enabled = (var.maintenance_configuration != null)
}

resource "azapi_update_resource" "disable_os_disk_public_network_access" {
  for_each  = var.enable_os_disk_public_network_access ? {} : var.virtual_machines
  type      = "Microsoft.Compute/disks@2023-01-02"
  name      = local.virtual_machine_os_disks[each.key].name
  parent_id = var.resource_group_id

  body = {
    properties = {
      networkAccessPolicy = "DenyAll"
    }
  }

  depends_on = [
    module.virtual_machines
  ]
}

module "virtual_machine_maintenance_configuration" {
  count   = var.maintenance_configuration == null ? 0 : 1
  source  = "Azure/avm-res-maintenance-maintenanceconfiguration/azurerm"
  version = "0.1.0"

  location            = var.location
  name                = local.maintenance_configuration_name
  resource_group_name = var.resource_group_name
  scope               = var.maintenance_configuration.scope
  tags                = var.resource_tags
  window              = var.maintenance_configuration.schedule

  extension_properties = {
    InGuestPatchMode = "User"
  }

  install_patches = {
    reboot_setting = "IfRequired"

    linux = {
      classifications_to_include = ["Critical", "Security"]
    }

    windows = {
      classifications_to_include = ["Critical", "Security"]
    }
  }
}
