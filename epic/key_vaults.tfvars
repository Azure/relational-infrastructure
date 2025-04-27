key_vaults = {
  production = {
    name                          = "secrets"
    location_name                 = "production"
    subscription_name             = "production"
    resource_group_name           = "shared"
    sku_name                      = "standard"
    enabled_for_disk_encryption   = true
    public_network_access_enabled = true
    soft_delete_retention_days    = 7

    network_acls = {
      bypass         = "AzureServices"
      default_action = "Allow"
    }
  }
}
