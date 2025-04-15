output "subscriptions" {
  value = {
    for subscription_name, subscription in var.subscriptions :
    subscription_name => {
      resources = (
        subscription.subscription_slot == local._s1
        ? {
          labels = {
            subscription = subscription_name
          }

          resource_groups      = try(module.az_subscription_1_infra_map[0].resource_groups, null)
          networks             = try(module.az_subscription_1_infra_map[0].networks, null)
          ddos_protection_plan = try(module.az_subscription_1_infra_map[0].ddos_protection_plan, null)
          key_vaults           = try(module.az_subscription_1_infra_map[0].key_vaults, null)
          private_endpoints    = try(module.az_subscription_1_infra_map[0].private_endpoints, null)
          virtual_machine_sets = try(module.az_subscription_1_infra_map[0].virtual_machine_sets, null)
        }
        : (
          subscription.subscription_slot == local._s2
          ? {
            labels = {
              subscription = subscription_name
            }

            resource_groups      = try(module.az_subscription_2_infra_map[0].resource_groups, null)
            networks             = try(module.az_subscription_2_infra_map[0].networks, null)
            ddos_protection_plan = try(module.az_subscription_2_infra_map[0].ddos_protection_plan, null)
            key_vaults           = try(module.az_subscription_2_infra_map[0].key_vaults, null)
            private_endpoints    = try(module.az_subscription_2_infra_map[0].private_endpoints, null)
            virtual_machine_sets = try(module.az_subscription_2_infra_map[0].virtual_machine_sets, null)
          }
          : null
        )
      )
    }
  }
}
