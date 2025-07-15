deployment_prefix  = "cwt05" # Provide a unique deployment name. 3-10 alphanumeric characters.
include_label_tags = true   # Maps Azure resources to the underlying infrastructure model.
# Recommended for debugging purposes.

locations = {
  shared = "canadacentral" # All Epic resources will be deployed to this region.

  # But you can add more locations as needed.
  # non_production = "westus"
}

subscriptions = {
  shared = {                                                             # By default, we deploy to a single subscription.
    subscription_id             = "00363a64-55c1-4807-92a4-7dfe011d5222" # Must be a valid Azure subscription ID
    default_resource_group_name = "shared"                               # Default resource group as defined in var.resource_groups
  }

  # But you can add more subscriptions as needed.
  # alt_production = { 
  #  subscription_id             = "34d69c09-3db4-44b0-8101-64fa34527c96"
  #  default_resource_group_name = "alt_shared"
  # }
}
