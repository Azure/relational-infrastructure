deployment_prefix         = "lock03"
include_label_tags        = true
ddos_protection_plan_name = null

lock_groups = {
  web_lock = {
    locked    = false
    read_only = false
  }

  database_lock = {
    locked    = false
    read_only = false
  }

  shared_lock = {
    locked    = false
    read_only = false
  }

  main_lock = {
    locked    = false
    read_only = false
  }
}

subscriptions = {
  primary = {
    default_resource_group_name = "shared"
    subscription_slot           = "az_subscription_1"
  }
}

locations = {
  primary = "canadacentral"
}

maintenance_schedules = {
  every_night = {
    repeat_every = {
      day = true
    }

    start_date_time_utc = "2025-04-20 06:00"
  }
}

resource_groups = {
  shared = {
    name              = "app-shared"
    location_name     = "primary"
    subscription_name = "primary"

    lock_groups = [
      "shared_lock",
      "main_lock"
    ]
  }

  web = {
    name              = "app-web"
    location_name     = "primary"
    subscription_name = "primary"

    lock_groups = [
      "web_lock",
      "main_lock"
    ]
  }

  database = {
    name              = "app-database"
    location_name     = "primary"
    subscription_name = "primary"

    lock_groups = [
      "database_lock",
      "main_lock"
    ]
  }
}

external_networks = {
  hyperspace = {
    address_space = "10.3.0.0/16"
    resource_id   = "/subscriptions/34d69c09-3db4-44b0-8101-64fa34527c96/resourceGroups/ep20-hyperspace-network/providers/Microsoft.Network/virtualNetworks/ep20-primary-hyperspace-net"

    subnets = {
      hyperspace = {
        address_space = "10.3.0.0/24"
        name          = "hyperspace"
      }

      private_endpoints = {
        address_space = "10.3.1.0/24"
        name          = "private-endpoints"
      }
    }
  }
}

networks = {
  main = {
    name                   = "shared-net"
    location_name          = "primary"
    subscription_name      = "primary"
    resource_group_name    = "shared"
    address_space          = "10.100.0.0/16"
    enable_ddos_protection = true

    lock_groups = [
      "shared_lock",
      "main_lock"
    ]

    peered_to = [
      "hyperspace"
    ]

    subnets = {
      front_end = {
        name          = "FrontEndSubnet"
        address_space = "10.100.0.0/24"
      }
      database = {
        name          = "DatabaseSubnet"
        address_space = "10.100.1.0/24"

        security_rules = {
          allow_in_from_front_end = {
            priority = 100
            allow = { in = { from = {
              subnet = {
                network_name = "main"
                subnet_name  = "front_end"
              }
            } } }
          }

          deny_all_else = {
            priority = 200
            deny     = { in = {} }
          }
        }
      }
    }
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
  web = {
    name                = "web"
    location_name       = "primary"
    key_vault_name      = "primary"
    subscription_name   = "primary"
    resource_group_name = "web"
    os_type             = "Windows"

    extensions = [
      "azure_monitor"
    ]

    maintenance = {
      schedule_name = "every_night"
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
        network_name = "main"
        subnet_name  = "front_end"
      }
    }
  }

  database = {
    name                = "database"
    location_name       = "primary"
    key_vault_name      = "primary"
    subscription_name   = "primary"
    resource_group_name = "database"
    os_type             = "Windows"

    extensions = [
      "azure_monitor"
    ]

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
        network_name = "main"
        subnet_name  = "database"
      }
    }
  }
}

virtual_machine_set_specs = {
  web = {
    vm_count = 2
    sku_size = "Standard_D4ads_v5"

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }

  database = {
    vm_count = 2
    sku_size = "Standard_D4ads_v5"

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }
}

key_vaults = {
  primary = {
    location_name                 = "primary"
    subscription_name             = "primary"
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
