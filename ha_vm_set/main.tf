module "virtualmachinescaleset" {
  source = "Azure/avm-res-compute-virtualmachinescaleset/azurerm"

  name                        = local.virtualmachinescaleset_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  extension_protected_setting = {}
  user_data_base64            = null
}

module "virtualmachines" {
  source = "Azure/avm-res-compute-virtualmachine/azurerm"
  count  = var.virtualmachine_count

  name                                  = local.virtualmachine_names[count.index]
  tags                                  = var.resource_tags
  location                              = var.location
  computer_name                         = local.virtualmachine_computer_names[count.index]
  data_disk_managed_disks               = local.virtualmachine_data_disks[count.index]
  os_disk                               = local.virtualmachine_os_disks[count.index]
  os_type                               = var.virtualmachine_os_type
  network_interfaces                    = local.virtualmachine_networkinterfaces[count.index]
  resource_group_name                   = var.resource_group_name
  source_image_reference                = var.virtualmachine_image_reference
  sku_size                              = var.virtualmachine_sku_size
  virtual_machine_scale_set_resource_id = module.virtualmachinescaleset.resource_id
  zone                                  = local.virtualmachine_zones[count.index]
}
