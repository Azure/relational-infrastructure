output "resources" {
  value = {
    scale_set_resource_id = (
      var.deploy_scale_set
      ? module.virtual_machine_scale_set[0].resource_id
      : null
    )

    scale_set_resource_name = (
      var.deploy_scale_set
      ? module.virtual_machine_scale_set[0].resource_name
      : null
    )

    virtual_machines = [
      for vm in module.virtual_machines : {
        resource_id   = vm.resource_id
        resource_name = vm.name
      }
    ]
  }
}
