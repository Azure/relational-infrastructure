module "virtual_machine_sets" {
  source   = "./modules/infra_map_vm_set"
  for_each = local.virtual_machine_sets_to_provision

  depends_on = [
    module.resource_groups,
    module.load_balancers,
    azurerm_application_security_group.application_security_group
  ]

  location                                      = each.value.location
  resource_group_name                           = each.value.resource_group_name
  resource_group_id                             = each.value.resource_group_id
  resource_tags                                 = each.value.resource_tags
  resource_prefix                               = each.value.resource_prefix
  virtual_machines                              = each.value.virtual_machines
  deploy_scale_set                              = each.value.deploy_scale_set
  virtual_machine_extensions_automatic_updates_enabled = each.value.virtual_machine_extensions_automatic_updates_enabled
  enable_virtual_machine_boot_diagnostics       = each.value.enable_boot_diagnostics
  user_assigned_identity_ids                    = each.value.user_assigned_identity_ids
  virtual_machine_system_assigned_identity_enabled = each.value.virtual_machine_system_assigned_identity_enabled
  virtual_machine_capacity_reservation_group_id = each.value.capacity_reservation_group_id
  virtual_machine_disk_controller_type          = each.value.disk_controller_type
  virtual_machine_image                         = each.value.virtual_machine_image
  virtual_machine_os_type                       = each.value.os_type
  virtual_machine_sku_size                      = each.value.sku_size
  virtual_machine_zone_distribution             = each.value.zone_distribution
  maintenance_configuration                     = each.value.maintenance_configuration
  virtual_machine_shutdown_schedule             = each.value.shutdown_schedule
  lock_mode                                     = each.value.lock_mode
  key_vault_configuration                       = each.value.key_vault_configuration
  virtual_machine_extensions                    = each.value.extensions
  virtual_machine_data_disks                    = each.value.data_disks
  virtual_machine_network_interfaces            = each.value.network_interfaces
  virtual_machine_os_disk                       = each.value.os_disk
}

resource "azurerm_network_interface_application_security_group_association" "asg_associations" {
  for_each = {
    for vm_nic in flatten([
      for vm_set_name, vm_set in module.virtual_machine_sets : [
        for vm_index, vm in vm_set.resources.virtual_machines : [
          for nic_name, nic in vm.network_interfaces : {
            vm_set_name = vm_set_name
            vm_index    = vm_index
            nic_name    = nic_name
            nic_id      = nic.resource_id
            key         = "${vm_set_name}_${vm_index}_${nic_name}"
          }
        ]
      ]
    ]) : vm_nic.key => vm_nic
  }

  network_interface_id          = each.value.nic_id
  application_security_group_id = azurerm_application_security_group.application_security_group[each.value.vm_set_name].id
}
