locals {
  # We only use [default_location] in places that are theoretically inconsequential, 
  # like resource group locations.

  default_location = values(var.locations)[0]

  private_link_resource_group_key = coalesce(
    var.private_link_resource_group_key,
    var.default_resource_group_key
  )

  locked_groups = {
    for group_name, group in var.lock_groups : group_name => {
      locked    = group.locked
      read_only = group.read_only
    } if group.locked
  }
}
