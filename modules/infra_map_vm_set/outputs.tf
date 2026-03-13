output "resources" {
  value = {
    scale_set = (
      var.deploy_scale_set
      ? {
        resource_id   = azurerm_orchestrated_virtual_machine_scale_set.virtual_machine_scale_set[0].id
        resource_name = local.virtual_machine_scale_set_name
      }
      : null
    )

    virtual_machines = {
      for vm_key, vm in module.virtual_machines : vm_key => {
        resource_id   = vm.resource_id
        resource_name = vm.name

        network_interfaces = {
          for nic_name, nic in vm.network_interfaces :
          nic_name => {
            resource_id        = nic.id
            resource_name      = nic.name
            private_ip_address = nic.private_ip_address
          }
        }
      }
    }
  }
}
