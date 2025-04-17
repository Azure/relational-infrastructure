output "resources" {
  value = {
    scale_set_resource_id                 = module.virtual_machine_scale_set.resource_id
    scale_set_resource_name               = module.virtual_machine_scale_set.resource_name

    virtual_machines = [
      for vm in module.virtual_machines : {
        resource_id   = vm.resource_id
        resource_name = vm.name
      }
    ]
  }
}
