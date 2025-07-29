storage_accounts = {
  # Only the WBS storage account is created by default.

  web_blob = {
    location_name       = "production"
    resource_group_name = "shared"
    subscription_name   = "production"
    name                = "wbs"
  }

  # Add additional storage accounts as needed....

  # alt_web_blob = {
  #   location_name       = "alt_production"
  #   resource_group_name = "web_blob"
  #   subscription_name   = "alt_production"
  #   name                = "alt-wbs"
  # }
}
