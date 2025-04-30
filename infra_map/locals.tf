locals {
  # This is kind of gnarly right now but Terraform but I couldn't
  # find a cleaner way to make subscriptions dynamic. We're ultimately limited
  # by Terraform's requirement that module provider configuration be static.

  subscriptions_by_slot = {
    for subscription_name, subscription in var.subscriptions :
    local.subscription_slots[subscription_name] => subscription
  }

  default_subscription_id = values(var.subscriptions)[0].subscription_id

  subscription_ids = [
    for i in range(0, 10) :
    try(values(var.subscriptions)[i].subscription_id, null)
  ]

  # Every azurerm needs to have a valid Azure subscription ID.
  # If the subscription ID is not set, we use the default subscription ID.
  # This is a workaround for the azurerm provider, which requires a valid subscription ID.

  provider_subscription_ids = [
    for i in range(0, 10) :
    try(values(var.subscriptions)[i].subscription_id, local.default_subscription_id)
  ]

  subscription_slot_names = [
    for i in range(0, 10) :
    "az_subscription_${i + 1}"
  ]

  subscription_names_by_slot = {
    for i in range(0, length(var.subscriptions)) :
    local.subscription_slot_names[i] =>
    keys(var.subscriptions)[i]
  }

  subscription_slots = {
    for i in range(0, length(var.subscriptions)) :
    keys(var.subscriptions)[i] =>
    local.subscription_slot_names[i]
  }

  deploy_to_subscription = {
    for i in range(0, 10) :
    local.subscription_slot_names[i] =>
    (local.subscription_ids[i] != null)
    ? 1 # Yes (module count == 1)
    : 0 # No  (module count == 0)
  }

  external_networks = {
    for network_name, network in merge(var.networks, var.external_networks)
    : network_name => {
      address_space = network.address_space

      subnets = {
        for subnet_name, subnet in network.subnets
        : subnet_name => {
          address_space = subnet.address_space
        }
      }
    }
  }
}
