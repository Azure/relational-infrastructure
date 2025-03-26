locals {
  az_subscription_1  = "az_subscription_1"
  az_subscription_2  = "az_subscription_2"
  az_subscription_3  = "az_subscription_3"
  az_subscription_4  = "az_subscription_4"
  az_subscription_5  = "az_subscription_5"
  az_subscription_6  = "az_subscription_6"
  az_subscription_7  = "az_subscription_7"
  az_subscription_8  = "az_subscription_8"
  az_subscription_9  = "az_subscription_9"
  az_subscription_10 = "az_subscription_10"

  subscriptions_by_slot = {
    for subscription_name, subscription in var.subscriptions
    : subscription.subscription_slot => subscription
  }
}
