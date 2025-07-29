private_endpoints = {
  key_vaults = {
    vm_secrets = {
      network_name        = "production"
      subnet_name         = "production"
      key_vault_name      = "vm_secrets"
      resource_group_name = "shared"

      dns_zone_group = {
        name                  = "default"
        private_dns_zone_name = "key_vault_private_endpoints"
      }
    }
  }
}
