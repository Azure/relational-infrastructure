private_endpoints = {
  key_vaults = {
    production_key_vault = {
      network_name        = "production"
      subnet_name         = "private_endpoints"
      key_vault_name      = "production"
      resource_group_name = "shared"

      dns_zone_group = {
        name = "default"
      }
    }
  }

  file_shares = {
    production_web_blob = {
      network_name        = "production"
      subnet_name         = "private_endpoints"
      share_name          = "production_web_blob"
      resource_group_name = "web_blob"

      dns_zone_group = {
        name = "default"
      }
    }
  }
}
