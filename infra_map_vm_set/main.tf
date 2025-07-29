module "virtual_machine_scale_set" {
  source = "Azure/avm-res-compute-virtualmachinescaleset/azurerm"
  count  = var.deploy_scale_set ? 1 : 0

  name                        = local.virtual_machine_scale_set_name
  lock                        = local.vmss_lock
  location                    = var.location
  resource_group_name         = var.resource_group_name
  extension_protected_setting = {}
  user_data_base64            = null
  tags                        = var.resource_tags

  managed_identities = {
    user_assigned_resource_ids = var.user_assigned_identity_ids
  }
}

module "virtual_machines" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  count   = var.virtual_machine_count
  version = "0.18.1" # For now; running into a problems with key vault + passwords

  name                                   = local.virtual_machine_names[count.index]
  lock                                   = local.vm_lock
  tags                                   = var.resource_tags
  location                               = var.location
  computer_name                          = local.virtual_machine_computer_names[count.index]
  extensions                             = var.virtual_machine_extensions
  boot_diagnostics                       = var.enable_virtual_machine_boot_diagnostics
  capacity_reservation_group_resource_id = var.virtual_machine_capacity_reservation_group_id
  disk_controller_type                   = var.virtual_machine_disk_controller_type
  data_disk_managed_disks                = local.virtual_machine_data_disks[count.index]
  enable_automatic_updates               = var.enable_automatic_updates
  encryption_at_host_enabled             = false
  os_disk                                = local.virtual_machine_os_disks[count.index]
  os_type                                = var.virtual_machine_os_type
  network_interfaces                     = local.virtual_machine_network_interfaces[count.index]
  shutdown_schedules                     = var.virtual_machine_shutdown_schedule
  patch_mode                             = "AutomaticByPlatform"
  patch_assessment_mode                  = "AutomaticByPlatform"
  resource_group_name                    = var.resource_group_name
  source_image_reference                 = var.virtual_machine_image.reference
  source_image_resource_id               = var.virtual_machine_image.id
  sku_size                               = var.virtual_machine_sku_size
  zone                                   = local.virtual_machine_zones[count.index]

  managed_identities = {
    system_assigned            = var.enable_vm_system_assigned_identity
    user_assigned_resource_ids = var.user_assigned_identity_ids
  }

  virtual_machine_scale_set_resource_id = (
    var.deploy_scale_set
    ? module.virtual_machine_scale_set[0].resource_id
    : null
  )

  generated_secrets_key_vault_secret_config = (
    var.generated_secrets_key_vault_secret_config == null ? null
    : local.virtual_machine_secret_configs[count.index]
  )

  maintenance_configuration_resource_ids = (
    var.maintenance_configuration == null ? {}
    : { config = module.virtual_machine_maintenance_configuration[0].resource_id }
  )

  bypass_platform_safety_checks_on_user_schedule_enabled = (var.maintenance_configuration != null)
}

resource "azapi_update_resource" "disable_os_disk_public_network_access" {
  count     = var.enable_os_disk_public_network_access ? 0 : var.virtual_machine_count
  type      = "Microsoft.Compute/disks@2023-01-02"
  name      = local.virtual_machine_os_disks[count.index].name
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
  count  = var.maintenance_configuration == null ? 0 : 1
  source = "Azure/avm-res-maintenance-maintenanceconfiguration/azurerm"

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