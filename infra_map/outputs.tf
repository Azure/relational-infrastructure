output "resource_groups" {
  value = {
    for group_name, group in merge(
      try(module.az_subscription_1_infra_map[0].resource_groups, {}),
      try(module.az_subscription_2_infra_map[0].resource_groups, {}),
      try(module.az_subscription_3_infra_map[0].resource_groups, {}),
      try(module.az_subscription_4_infra_map[0].resource_groups, {}),
      try(module.az_subscription_5_infra_map[0].resource_groups, {}),
      try(module.az_subscription_6_infra_map[0].resource_groups, {}),
      try(module.az_subscription_7_infra_map[0].resource_groups, {}),
      try(module.az_subscription_8_infra_map[0].resource_groups, {}),
      try(module.az_subscription_9_infra_map[0].resource_groups, {}),
      try(module.az_subscription_10_infra_map[0].resource_groups, {})
    ) :
    group_name => group
  }
}

output "networks" {
  value = {
    for network_key, network in merge(
      try(module.az_subscription_1_infra_map[0].networks, {}),
      try(module.az_subscription_2_infra_map[0].networks, {}),
      try(module.az_subscription_3_infra_map[0].networks, {}),
      try(module.az_subscription_4_infra_map[0].networks, {}),
      try(module.az_subscription_5_infra_map[0].networks, {}),
      try(module.az_subscription_6_infra_map[0].networks, {}),
      try(module.az_subscription_7_infra_map[0].networks, {}),
      try(module.az_subscription_8_infra_map[0].networks, {}),
      try(module.az_subscription_9_infra_map[0].networks, {}),
      try(module.az_subscription_10_infra_map[0].networks, {})
    ) :
    network_key => network
  }
}

output "ddos_protection_plans" {
  value = {
    for subscription_key, subscription in var.subscriptions :
    subscription_key => local.ddos_protection_plans_by_subscription[local.subscription_slots[subscription_key]]
  }
}

output "key_vaults" {
  value = {
    for vault_name, vault in merge(
      try(module.az_subscription_1_infra_map[0].key_vaults, {}),
      try(module.az_subscription_2_infra_map[0].key_vaults, {}),
      try(module.az_subscription_3_infra_map[0].key_vaults, {}),
      try(module.az_subscription_4_infra_map[0].key_vaults, {}),
      try(module.az_subscription_5_infra_map[0].key_vaults, {}),
      try(module.az_subscription_6_infra_map[0].key_vaults, {}),
      try(module.az_subscription_7_infra_map[0].key_vaults, {}),
      try(module.az_subscription_8_infra_map[0].key_vaults, {}),
      try(module.az_subscription_9_infra_map[0].key_vaults, {}),
      try(module.az_subscription_10_infra_map[0].key_vaults, {})
    ) :
    vault_name => vault
  }
}

output "private_endpoints" {
  value = {
    for endpoint_name, endpoint in merge(
      try(module.az_subscription_1_infra_map[0].private_endpoints, {}),
      try(module.az_subscription_2_infra_map[0].private_endpoints, {}),
      try(module.az_subscription_3_infra_map[0].private_endpoints, {}),
      try(module.az_subscription_4_infra_map[0].private_endpoints, {}),
      try(module.az_subscription_5_infra_map[0].private_endpoints, {}),
      try(module.az_subscription_6_infra_map[0].private_endpoints, {}),
      try(module.az_subscription_7_infra_map[0].private_endpoints, {}),
      try(module.az_subscription_8_infra_map[0].private_endpoints, {}),
      try(module.az_subscription_9_infra_map[0].private_endpoints, {}),
      try(module.az_subscription_10_infra_map[0].private_endpoints, {})
    ) :
    endpoint_name => endpoint
  }
}

output "virtual_machine_sets" {
  value = {
    for vm_set_name, vm_set in merge(
      try(module.az_subscription_1_infra_map[0].virtual_machine_sets, {}),
      try(module.az_subscription_2_infra_map[0].virtual_machine_sets, {}),
      try(module.az_subscription_3_infra_map[0].virtual_machine_sets, {}),
      try(module.az_subscription_4_infra_map[0].virtual_machine_sets, {}),
      try(module.az_subscription_5_infra_map[0].virtual_machine_sets, {}),
      try(module.az_subscription_6_infra_map[0].virtual_machine_sets, {}),
      try(module.az_subscription_7_infra_map[0].virtual_machine_sets, {}),
      try(module.az_subscription_8_infra_map[0].virtual_machine_sets, {}),
      try(module.az_subscription_9_infra_map[0].virtual_machine_sets, {}),
      try(module.az_subscription_10_infra_map[0].virtual_machine_sets, {})
    ) :
    vm_set_name => vm_set
  }
}
