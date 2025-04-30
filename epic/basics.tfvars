deployment_prefix  = "gamma"
include_label_tags = true

locations = {
  production     = "canadacentral"
  alt_production = "francecentral"
}

subscriptions = {
  production = {
    subscription_id             = "00363a64-55c1-4807-92a4-7dfe011d5222"
    default_resource_group_name = "shared"
  }

  alt_production = {
    subscription_id             = "34d69c09-3db4-44b0-8101-64fa34527c96"
    default_resource_group_name = "alt_shared"
  }
}

tags = {
  epic-env = "production"
}

