locals {
  subscriptions_by_slot = {
    for subscription_name, subscription in var.subscriptions
    : subscription.subscription_slot => subscription
  }
}
