locals {
  # We only use [default_location] in places that are theoretically inconsequential, 
  # like resource group locations.

  default_location = var.locations[var.default_location_key_reference]

  locked_groups = {
    for group_name, group in var.lock_groups : group_name => {
      locked    = group.locked
      read_only = group.read_only
    } if group.locked
  }
}
