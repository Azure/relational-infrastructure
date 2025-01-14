output "virtualmachine_ids_by_zone" {
  value = [for vm in module.virtualmachines : vm.resource_id]
}

output "virtualmachinescaleset_id" {
  value = module.virtualmachinescaleset.resource_id
}
