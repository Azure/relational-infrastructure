file_shares = {
  # By default, we include the production WBS file share.
  # Add more file shares as needed.

  production_web_blob = {
    location_name        = "production"
    resource_group_name  = "web_blob"
    storage_account_name = "web_blob"
    subscription_name    = "production"
    name                 = "wbs"
    quota_gb             = 1000
  }
}
