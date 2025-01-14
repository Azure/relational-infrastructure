module "virtual_machine_sets" {
  source   = "../high_availability_virtual_machine_set"
  for_each = var.virtual_machine_sets

  location = each.value.location
}
