data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

module "virtual_machine_scale_set" {
  source = "Azure/avm-res-compute-virtualmachinescaleset/azurerm"

  name                        = local.virtual_machine_scale_set_name
  lock                        = local.vmss_lock
  location                    = var.location
  resource_group_name         = var.resource_group_name
  extension_protected_setting = {}
  user_data_base64            = null
}

module "virtual_machines" {
  source = "Azure/avm-res-compute-virtualmachine/azurerm"
  count  = var.virtual_machine_count

  name                                      = local.virtual_machine_names[count.index]
  lock                                      = local.vm_lock
  tags                                      = var.resource_tags
  location                                  = var.location
  computer_name                             = local.virtual_machine_computer_names[count.index]
  extensions                                = var.virtual_machine_extensions
  boot_diagnostics                          = var.enable_virtual_machine_boot_diagnostics
  capacity_reservation_group_resource_id    = var.virtual_machine_capacity_reservation_group_id
  disk_controller_type                      = var.virtual_machine_disk_controller_type
  data_disk_managed_disks                   = local.virtual_machine_data_disks[count.index]
  enable_automatic_updates                  = var.enable_automatic_updates
  encryption_at_host_enabled                = false
  os_disk                                   = local.virtual_machine_os_disks[count.index]
  os_type                                   = var.virtual_machine_os_type
  network_interfaces                        = local.virtual_machine_network_interfaces[count.index]
  patch_mode                                = "AutomaticByPlatform"
  patch_assessment_mode                     = "AutomaticByPlatform"
  resource_group_name                       = var.resource_group_name
  source_image_reference                    = var.virtual_machine_image.reference
  source_image_resource_id                  = var.virtual_machine_image.id
  sku_size                                  = var.virtual_machine_sku_size
  virtual_machine_scale_set_resource_id     = module.virtual_machine_scale_set.resource_id
  zone                                      = local.virtual_machine_zones[count.index]
  generated_secrets_key_vault_secret_config = var.generated_secrets_key_vault_secret_config == null ? null : local.virtual_machine_secret_configs[count.index]
}

resource "azapi_update_resource" "disable_os_disk_public_network_access" {
  count     = var.enable_os_disk_public_network_access ? 0 : var.virtual_machine_count
  type      = "Microsoft.Compute/disks@2023-01-02"
  name      = local.virtual_machine_os_disks[count.index].name
  parent_id = data.azurerm_resource_group.resource_group.id

  body = {
    properties = {
      networkAccessPolicy = "DenyAll"
    }
  }
}
