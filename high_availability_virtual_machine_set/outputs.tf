output "virtual_machine_ids_by_zone" {
  value = [for vm in module.virtual_machines : vm.resource_id]
}

output "virtualmachinescaleset_id" {
  value = module.virtual_machine_scale_set.resource_id
}
