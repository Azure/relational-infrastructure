locals {
  subscriptions_by_slot = {
    for subscription_name, subscription in var.subscriptions :
    local.subscription_slots[subscription_name] => subscription
  }

  default_subscription_id = values(var.subscriptions)[0].subscription_id

  subscription_ids = [
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
    contains(keys(local.subscription_names_by_slot), local.subscription_slot_names[i])
    ? 1 # Yes (module count == 1)
    : 0 # No  (module count == 0)
  }
}
