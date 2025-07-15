key_vaults = {
  # By default, we include a single production key vault.
  # By default, local passwords for VMs defined in var.virtual_machine_sets are defined here.
  # Add more key vaults as your needs dictate.

  vm_secrets = {
    name                          = "top-secrets"
    location_name                 = "shared"
    subscription_name             = "shared"
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
