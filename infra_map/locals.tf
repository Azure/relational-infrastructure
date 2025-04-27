locals {
  subscriptions_by_slot = {
    for subscription_name, subscription in var.subscriptions :
    subscription_slots[subscription_name] => subscription
  }

  subscription_names_by_slot = {
    for subscription_name in var.subscriptions :
    subscription.subscription_slot => subscription_name
  }

  default_subscription_id = values(var.subscriptions)[0].subscription_id

  subscription_ids = [
    for i in range(0, 10) :
    try(values(var.subscriptions)[i].subscription_id, local.default_subscription_id)
  ]

  subscription_slots = {
    for i in range(0, count(var.subscriptions)) :
    try(keys(var.subscriptions)[i], null) =>
    "az_subscription_${i + 1}"
    if each.key != null
  }

  virtual_network_outputs = {
    for network_name, network in var.networks :
    network_name => {
      resource_id = (
        network.subscription_name == local.subscription_names_by_slot[local._s1]
        ? try(module.az_subscription_1_infra_map[0].networks[network_name].resource_id, null)
        : try(module.az_subscription_2_infra_map[0].networks[network_name].resource_id, null)
      )
      resource_name = (
        network.subscription_name == local.subscription_names_by_slot[local._s1]
        ? try(module.az_subscription_1_infra_map[0].networks[network_name].resource_name, null)
        : try(module.az_subscription_2_infra_map[0].networks[network_name].resource_name, null)
      )
    }
  }

  resource_group_outputs = {
    for group_name, group in var.resource_groups :
    group_name => {
      resource_id = (
        group.subscription_name == local.subscription_names_by_slot[local._s1]
        ? try(module.az_subscription_1_infra_map[0].resource_groups[group_name].resource_id, null)
        : try(module.az_subscription_2_infra_map[0].resource_groups[group_name].resource_id, null)
      )
      resource_name = (
        group.subscription_name == local.subscription_names_by_slot[local._s1]
        ? try(module.az_subscription_1_infra_map[0].resource_groups[group_name].resource_name, null)
        : try(module.az_subscription_2_infra_map[0].resource_groups[group_name].resource_name, null)
      )
    }
  }

  peerings = tomap({
    for peering in flatten([
      for from_network_name, from_network in var.networks : [
        for to_network_name in from_network.peered_to : {
          peer_from_network_name    = from_network_name
          peer_to_network_name      = to_network_name
          from_subscription_name    = from_network.subscription_name
          from_resource_group_name  = local.resource_group_outputs[from_network.resource_group_name].resource_name
          from_virtual_network_name = local.virtual_network_outputs[from_network_name].resource_name

          to_remote_virtual_network_id = coalesce(
            try(var.external_networks[to_network_name].resource_id, null),        # Peer to an external network
            try(local.virtual_network_outputs[to_network_name].resource_id, null) # Peer to an internal network
          )
        }
      ]
    ]) : "peer-${peering.peer_from_network_name}-to-${peering.peer_to_network_name}" => peering
  })
}
