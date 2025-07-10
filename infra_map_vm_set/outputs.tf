output "resources" {
  value = {
    scale_set = (
      var.deploy_scale_set
      ? {
        resource_id   = module.virtual_machine_scale_set[0].resource_id
        resource_name = module.virtual_machine_scale_set[0].resource_name
      }
      : null
    )

    virtual_machines = [
      for vm in module.virtual_machines : {
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
    ]
  }
}
