locals {
  resource_groups_to_provision = {
    for resource_group_key, resource_group in var.resource_groups : resource_group_key => {
      name = local.resource_group_names[resource_group_key]
      tags = local.resource_group_tags[resource_group_key]

      location = resource_group.location_key_reference == null ? values(var.locations)[0] : var.locations[resource_group.location_key_reference]

      lock = (
        length([
          for group in resource_group.lock_groups_key_reference :
          group if contains(keys(local.locked_groups), group)
        ]) > 0
        ? (
          anytrue([
            for group in resource_group.lock_groups_key_reference :
            contains(keys(local.locked_groups), group)
            && try(local.locked_groups[group].read_only, false)
          ])
          ? { kind = local.lock_modes.read_only }
          : { kind = local.lock_modes.no_delete }
        )
        : null
      )
    }
  }
}
