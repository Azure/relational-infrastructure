deployment_prefix  = "epcan01"
include_label_tags = true

locations = {
  production = "canadacentral"
}

subscriptions = {
  production = {
    subscription_id             = "00363a64-55c1-4807-92a4-7dfe011d5222"
    default_resource_group_name = "shared"
  }
}

tags = {
  epic-env = "production"
}

