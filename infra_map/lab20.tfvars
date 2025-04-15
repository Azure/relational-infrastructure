deployment_prefix         = "ep20"
include_label_tags        = true
ddos_protection_plan_name = null
enable_full_network_mesh  = false

tags = {
  epic-env = "production"
}

locations = {
  primary = "canadacentral"
  alt     = "francecentral"
}

subscriptions = {
  main = {
    default_resource_group_name = "main_default"
    subscription_slot           = "az_subscription_1"
  }
  hyperspace = {
    default_resource_group_name = "hyperspace_default"
    subscription_slot           = "az_subscription_2"
  }
}

resource_groups = {
  main_default = {
    subscription_name = "main"
    name              = "main-default"
  }
  hyperspace_default = {
    subscription_name = "hyperspace"
    name              = "hyperspace-default"
  }
  main_key_vaults = {
    subscription_name = "main"
    name              = "main-key-vaults"
  }
  hyperspace_key_vaults = {
    subscription_name = "hyperspace"
    name              = "hyperspace-key-vaults"
  }
  main_network = {
    subscription_name = "main"
    name              = "main-network"
  }
  hyperspace_network = {
    subscription_name = "hyperspace"
    name              = "hyperspace-network"
  }
  bca_web = {
    subscription_name = "main"
    name              = "bca-web"
  }
  mpsql = {
    subscription_name = "main"
    name              = "mpsql"
  }
  hyperspace_web = {
    subscription_name = "main"
    name              = "hyperspace-web"
  }
  hyperspace = {
    subscription_name = "hyperspace"
    name              = "hyperspace"
  }
}

networks = {
  primary_dmz = {
    name                   = "primary-dmz-net"
    location_name          = "primary"
    subscription_name      = "main"
    resource_group_name    = "main_network"
    address_space          = "10.0.0.0/16"
    enable_ddos_protection = true

    subnets = {
      firewall = {
        name          = "FirewallSubnet"
        address_space = "10.0.0.0/24"
      }
      production = {
        address_space = "10.0.1.0/24"
      }
      non_production = {
        address_space = "10.0.2.0/24"
      }
    }
  }

  primary_shared_infra = {
    name                = "primary-shared-infra-net"
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "main_network"
    address_space       = "10.1.0.0/16"

    subnets = {
      gateway = {
        name           = "GatewaySubnet"
        address_space  = "10.1.0.0/24"
        security_rules = null
      }
      management = {
        address_space = "10.1.1.0/24"
      }
    }

    peered_to = [
      "primary_hyperspace",
      "primary_hyperspace_web",
      "primary_main"
    ]
  }

  primary_main = {
    name                = "primary-main-net"
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "main_network"
    address_space       = "10.2.0.0/16"

    subnets = {
      cogito = {
        address_space = "10.2.0.0/24"

        security_rules = {
          allow_https_from_dmz_production = {
            priority = 100
            allow = { in = { from = {
              port_range = 443
              subnet = {
                network_name = "primary_dmz"
                subnet_name  = "production"
              } } }
            }
          }
          deny_all_else_inbound = {
            priority = 200
            deny     = { in = {} }
          }
        }
      }
      odb = {
        address_space = "10.2.1.0/24"
      }
      wss = {
        address_space = "10.2.2.0/24"
      }
      private_endpoints = {
        address_space = "10.2.3.0/24"
      }
    }

    peered_to = [
      "primary_hyperspace",
      "primary_hyperspace_web",
      "primary_shared_infra"
    ]
  }

  primary_hyperspace = {
    name                = "primary-hyperspace-net"
    location_name       = "primary"
    subscription_name   = "hyperspace"
    resource_group_name = "hyperspace_network"
    address_space       = "10.3.0.0/16"

    subnets = {
      hyperspace = {
        address_space = "10.3.0.0/24"
      }
      private_endpoints = {
        address_space = "10.3.1.0/24"
        name          = "private-endpoints"
      }
    }

    peered_to = [
      "primary_hyperspace_web",
      "primary_main",
      "primary_shared_infra"
    ]
  }

  primary_hyperspace_web = {
    name                = "primary-hyperspace-web-net"
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "main_network"
    address_space       = "10.4.0.0/16"

    subnets = {
      hyperspace_web = {
        address_space = "10.4.0.0/24"
      }
    }

    peered_to = [
      "primary_hyperspace",
      "primary_main",
      "primary_shared_infra"
    ]
  }

  alt_dmz = {
    name                   = "alt-dmz-net"
    location_name          = "alt"
    subscription_name      = "main"
    resource_group_name    = "main_network"
    address_space          = "10.10.0.0/16"
    enable_ddos_protection = true

    subnets = {
      firewall = {
        name          = "FirewallSubnet"
        address_space = "10.10.0.0/24"
      }
      production = {
        address_space = "10.10.1.0/24"
      }
      non_production = {
        address_space = "10.10.2.0/24"
      }
    }
  }

  alt_shared_infra = {
    name                = "alt-shared-infra-net"
    location_name       = "alt"
    subscription_name   = "main"
    resource_group_name = "main_network"
    address_space       = "10.11.0.0/16"

    subnets = {
      gateway = {
        name          = "GatewaySubnet"
        address_space = "10.11.0.0/24"
      }
      management = {
        address_space = "10.11.1.0/24"
      }
    }

    peered_to = [
      "alt_hyperspace",
      "alt_hyperspace_web",
      "alt_main"
    ]
  }

  alt_main = {
    name                = "alt-main-net"
    location_name       = "alt"
    subscription_name   = "main"
    resource_group_name = "main_network"
    address_space       = "10.12.0.0/16"

    subnets = {
      cogito = {
        address_space = "10.12.0.0/24"
      }
      odb = {
        address_space = "10.12.1.0/24"
      }
      wss = {
        address_space = "10.12.2.0/24"
      }
      private_endpoints = {
        address_space = "10.12.3.0/24"
        name          = "private-endpoints"
      }
    }

    peered_to = [
      "alt_hyperspace",
      "alt_hyperspace_web",
      "alt_shared_infra"
    ]
  }

  alt_hyperspace = {
    name                = "alt-hyperspace-net"
    location_name       = "alt"
    subscription_name   = "hyperspace"
    resource_group_name = "hyperspace_network"
    address_space       = "10.13.0.0/16"

    subnets = {
      hyperspace = {
        address_space = "10.13.0.0/24"
      }
      private_endpoints = {
        address_space = "10.13.1.0/24"
        name          = "private-endpoints"
      }
    }

    peered_to = [
      "alt_hyperspace_web",
      "alt_main",
      "alt_shared_infra"
    ]
  }

  alt_hyperspace_web = {
    name                = "alt-hyperspace-web-net"
    location_name       = "alt"
    subscription_name   = "main"
    resource_group_name = "main_network"
    address_space       = "10.14.0.0/16"

    subnets = {
      hyperspace_web = {
        address_space = "10.14.0.0/24"
      }
    }

    peered_to = [
      "alt_hyperspace",
      "alt_main",
      "alt_shared_infra"
    ]
  }
}

virtual_machine_extensions = {
  azure_monitor = {
    name                       = "AzureMonitorWindowsAgent"
    publisher                  = "Microsoft.Azure.Monitor"
    type                       = "AzureMonitorWindowsAgent"
    type_handler_version       = "1.2"
    auto_upgrade_minor_version = true
    automatic_upgrade_enabled  = true
    settings                   = null
  }
}

virtual_machine_sets = {
  alt_bca_web = {
    name                = "altbcw"
    location_name       = "alt"
    key_vault_name      = "alt"
    subscription_name   = "main"
    resource_group_name = "bca_web"
    os_type             = "Windows"

    extensions = [
      "azure_monitor"
    ]

    tags = {
      epic-app = "bcaweb"
    }

    image = {
      reference = {
        offer     = "WindowsServer"
        publisher = "MicrosoftWindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
      }
    }

    network_interfaces = {
      general = {
        network_name = "alt_main"
        subnet_name  = "wss"
      }
    }
  }

  alt_hyperspace_web = {
    name                = "althsw"
    location_name       = "alt"
    key_vault_name      = "alt"
    subscription_name   = "main"
    resource_group_name = "hyperspace_web"
    os_type             = "Windows"

    extensions = [
      "azure_monitor"
    ]

    tags = {
      epic-app = "hsw"
    }

    image = {
      reference = {
        offer     = "WindowsServer"
        publisher = "MicrosoftWindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
      }
    }

    network_interfaces = {
      general = {
        network_name = "alt_hyperspace_web"
        subnet_name  = "hyperspace_web"
      }
    }
  }

  alt_hyperspace = {
    name                = "althsp"
    location_name       = "alt"
    key_vault_name      = "alt_hyperspace"
    subscription_name   = "hyperspace"
    resource_group_name = "hyperspace"
    os_type             = "Windows"

    extensions = [
      "azure_monitor"
    ]

    tags = {
      epic-app = "hyperspace"
    }

    image = {
      reference = {
        offer     = "WindowsServer"
        publisher = "MicrosoftWindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
      }
    }

    network_interfaces = {
      general = {
        network_name = "alt_hyperspace"
        subnet_name  = "hyperspace"
      }
    }
  }

  alt_mpsql = {
    name                = "altsql"
    location_name       = "alt"
    key_vault_name      = "alt"
    subscription_name   = "main"
    resource_group_name = "mpsql"
    os_type             = "Windows"

    tags = {
      epic-app = "mpsql"
    }

    data_disks = {
      data = {
        lun = 0
      }
      logs = {
        lun = 1
      }
    }

    image = {
      reference = {
        offer     = "WindowsServer"
        publisher = "MicrosoftWindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
      }
    }

    network_interfaces = {
      general = {
        network_name = "alt_shared_infra"
        subnet_name  = "management"
      }
    }
  }

  primary_bca_web = {
    name                = "prmbcw"
    location_name       = "primary"
    key_vault_name      = "primary"
    subscription_name   = "main"
    resource_group_name = "bca_web"
    os_type             = "Windows"

    tags = {
      epic-app = "bcaweb"
    }

    image = {
      reference = {
        offer     = "WindowsServer"
        publisher = "MicrosoftWindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
      }
    }

    network_interfaces = {
      general = {
        network_name = "primary_main"
        subnet_name  = "wss"
      }
    }
  }

  primary_hyperspace_web = {
    name                = "prmhsw"
    location_name       = "primary"
    key_vault_name      = "primary"
    subscription_name   = "main"
    resource_group_name = "hyperspace_web"
    os_type             = "Windows"

    extensions = [
      "azure_monitor"
    ]

    tags = {
      epic-app = "hsw"
    }

    image = {
      reference = {
        offer     = "WindowsServer"
        publisher = "MicrosoftWindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
      }
    }

    network_interfaces = {
      general = {
        network_name = "primary_hyperspace_web"
        subnet_name  = "hyperspace_web"
      }
    }
  }

  primary_hyperspace = {
    name                = "prmhsp"
    location_name       = "primary"
    key_vault_name      = "primary_hyperspace"
    subscription_name   = "hyperspace"
    resource_group_name = "hyperspace"
    os_type             = "Windows"

    extensions = [
      "azure_monitor"
    ]

    tags = {
      epic-app = "hyperspace"
    }

    image = {
      reference = {
        offer     = "WindowsServer"
        publisher = "MicrosoftWindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
      }
    }

    network_interfaces = {
      general = {
        network_name = "primary_hyperspace"
        subnet_name  = "hyperspace"
      }
    }
  }

  primary_mpsql = {
    name                = "prmsql"
    location_name       = "primary"
    key_vault_name      = "primary"
    subscription_name   = "main"
    resource_group_name = "mpsql"
    os_type             = "Windows"

    tags = {
      epic-app = "mpsql"
    }

    data_disks = {
      data = {
        lun = 0
      }
      logs = {
        lun = 1
      }
    }

    image = {
      reference = {
        offer     = "WindowsServer"
        publisher = "MicrosoftWindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
      }
    }

    network_interfaces = {
      general = {
        network_name = "primary_shared_infra"
        subnet_name  = "management"
      }
    }
  }
}

virtual_machine_set_specs = {
  alt_mpsql = {
    vm_count = 2
    sku_size = "Standard_D4ads_v5"

    data_disks = {
      data = {
        disk_size_gb         = 128
        storage_account_type = "Premium_LRS"
      }
      logs = {
        disk_size_gb         = 128
        storage_account_type = "Premium_LRS"
      }
    }

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }

  alt_bca_web = {
    vm_count = 5
    sku_size = "Standard_D4ads_v5"

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }

  alt_hyperspace_web = {
    vm_count = 5
    sku_size = "Standard_D4ads_v5"

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }

  alt_hyperspace = {
    vm_count = 5
    sku_size = "Standard_D4ads_v5"

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }

  primary_mpsql = {
    vm_count = 3
    sku_size = "Standard_D4ads_v5"

    data_disks = {
      data = {
        disk_size_gb         = 128
        storage_account_type = "Premium_LRS"
      }
      logs = {
        disk_size_gb         = 128
        storage_account_type = "Premium_LRS"
      }
    }

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }

  primary_bca_web = {
    vm_count = 10
    sku_size = "Standard_D4ads_v5"

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }

  primary_hyperspace_web = {
    vm_count = 5
    sku_size = "Standard_D4ads_v5"

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }

  primary_hyperspace = {
    vm_count = 5
    sku_size = "Standard_D4ads_v5"

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }
}

virtual_machine_set_zone_distribution = {
  primary_bca_web = {
    custom = {
      "1" = 2
      "2" = 8
    }
  }
}

storage_accounts = {
  account_a = {
    shares = {

    }
  }
}

netapp_accounts = {
  account_b = {

  }
}

file_shares = {
  share_a = {
    storage_account_name = "account_a"
    netapp_account_name  = "account_b"
  }
}

key_vaults = {
  primary = {
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "main_key_vaults"
    #name                          = "primary-kv"
    sku_name                      = "standard"
    enabled_for_disk_encryption   = true
    public_network_access_enabled = true #Only for testing purposes
    soft_delete_retention_days    = 7

    network_acls = {
      bypass         = "AzureServices"
      default_action = "Allow"
      # ip_rules       = []
      # virtual_network_subnet_ids = [
      #   module.networks.primary_shared_infra.subnets.management.id
      # ]
    }

    tags = {
      epic-env     = "production"
      epic-service = "security"
    }
  }

  primary_hyperspace = {
    location_name       = "primary"
    subscription_name   = "hyperspace"
    resource_group_name = "hyperspace_key_vaults"
    #name                          = "primary-kv"
    sku_name                      = "standard"
    enabled_for_disk_encryption   = true
    public_network_access_enabled = true #Only for testing purposes
    soft_delete_retention_days    = 7

    network_acls = {
      bypass         = "AzureServices"
      default_action = "Allow"
      # ip_rules       = []
      # virtual_network_subnet_ids = [
      #   module.networks.primary_shared_infra.subnets.management.id
      # ]
    }

    tags = {
      epic-env     = "production"
      epic-service = "security"
    }
  }

  #Secondary Key Vault with minimal configuration
  alt = {
    location_name                 = "alt"
    subscription_name             = "main"
    resource_group_name           = "main_key_vaults"
    purge_protection_enabled      = true
    public_network_access_enabled = true #Only for testing purposes
    soft_delete_retention_days    = 7

    network_acls = {
      bypass         = "AzureServices"
      default_action = "Allow"
      # ip_rules       = []
      # virtual_network_subnet_ids = [
      #   module.networks.primary_shared_infra.subnets.management.id
      # ]
    }

    tags = {
      epic-env     = "production"
      epic-service = "security"
    }
  }

  alt_hyperspace = {
    location_name                 = "alt"
    subscription_name             = "hyperspace"
    resource_group_name           = "hyperspace_key_vaults"
    purge_protection_enabled      = true
    public_network_access_enabled = true #Only for testing purposes
    soft_delete_retention_days    = 7

    network_acls = {
      bypass         = "AzureServices"
      default_action = "Allow"
      # ip_rules       = []
      # virtual_network_subnet_ids = [
      #   module.networks.primary_shared_infra.subnets.management.id
      # ]
    }

    tags = {
      epic-env     = "production"
      epic-service = "security"
    }
  }
}

# Private endpoints configuration example
private_endpoints = {
  # Key Vault Private Endpoints
  key_vaults = {
    primary = {
      network_name   = "primary_main"      # This references the network key in the networks variable
      subnet_name    = "private_endpoints" # This references the subnet key in your networks.subnets variable
      key_vault_name = "primary"           # This references the key vault key in your key_vaults variable

      # Optional: Specify a static IP 
      # private_ip     = "10.1.1.10"
      # Optional: Custom endpoint name
      # name           = "custom-endpoint-name"
      dns_zone_group = {
        name = "default"
        # Specify existing private DNS zone IDs if available
        # private_dns_zone_ids = [
        #   "/subscriptions/sub-id/resourceGroups/dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
        # ]
      }
    },
    alt = {
      network_name   = "alt_main"
      subnet_name    = "private_endpoints"
      key_vault_name = "alt"
      # Customize the endpoint name (optional)
      #name = "custom-alt-kv-endpoint"
    }
    primary_hyperspace = {
      network_name   = "primary_hyperspace" # This references the network key in the networks variable
      subnet_name    = "private_endpoints"  # This references the subnet key in your networks.subnets variable
      key_vault_name = "primary_hyperspace" # This references the key vault key in your key_vaults variable

      # Optional: Specify a static IP 
      # private_ip     = "10.1.1.10"
      # Optional: Custom endpoint name
      # name           = "custom-endpoint-name"
      dns_zone_group = {
        name = "default"
        # Specify existing private DNS zone IDs if available
        # private_dns_zone_ids = [
        #   "/subscriptions/sub-id/resourceGroups/dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
        # ]
      }
    },
    alt_hyperspace = {
      network_name   = "alt_hyperspace"
      subnet_name    = "private_endpoints"
      key_vault_name = "alt_hyperspace"
      # Customize the endpoint name (optional)
      #name = "custom-alt-kv-endpoint"
    }
  }

  # Storage Account Private Endpoints (example for when storage accounts are implemented)
  # storage_accounts = {
  #   primary_blob = {
  #     network_name         = "primary_main"
  #     subnet_name          = "private_endpoints"
  #     storage_account_name = "primary"       # This would reference a storage account key
  #     subresource_name     = "blob"
  #     dns_zone_group = {
  #       name = "default"
  #       private_dns_zone_ids = [
  #         "/subscriptions/sub-id/resourceGroups/dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
  #       ]
  #     }
  #   },
  #   primary_file = {
  #     network_name         = "primary_main"
  #     subnet_name          = "private_endpoints"
  #     storage_account_name = "primary"
  #     subresource_name     = "file"
  #   }
  # }
}
