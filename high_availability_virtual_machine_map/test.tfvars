deployment_prefix         = "eptst50"
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

networks = {
  primary_dmz = {
    name                   = "primary-dmz-net"
    location_name          = "primary"
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
    name          = "primary-shared-infra-net"
    location_name = "primary"
    address_space = "10.1.0.0/16"

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
    name          = "primary-main-net"
    location_name = "primary"
    address_space = "10.2.0.0/16"

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
    }

    peered_to = [
      "primary_hyperspace",
      "primary_hyperspace_web",
      "primary_shared_infra"
    ]
  }

  primary_hyperspace = {
    name          = "primary-hyperspace-net"
    location_name = "primary"
    address_space = "10.3.0.0/16"

    subnets = {
      hyperspace = {
        address_space = "10.3.0.0/24"
      }
    }

    peered_to = [
      "primary_hyperspace_web",
      "primary_main",
      "primary_shared_infra"
    ]
  }

  primary_hyperspace_web = {
    name          = "primary-hyperspace-web-net"
    location_name = "primary"
    address_space = "10.4.0.0/16"

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
    name          = "alt-shared-infra-net"
    location_name = "alt"
    address_space = "10.11.0.0/16"

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
    name          = "alt-main-net"
    location_name = "alt"
    address_space = "10.12.0.0/16"

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
    }

    peered_to = [
      "alt_hyperspace",
      "alt_hyperspace_web",
      "alt_shared_infra"
    ]
  }

  alt_hyperspace = {
    name          = "alt-hyperspace-net"
    location_name = "alt"
    address_space = "10.13.0.0/16"

    subnets = {
      hyperspace = {
        address_space = "10.13.0.0/24"
      }
    }

    peered_to = [
      "alt_hyperspace_web",
      "alt_main",
      "alt_shared_infra"
    ]
  }

  alt_hyperspace_web = {
    name          = "alt-hyperspace-web-net"
    location_name = "alt"
    address_space = "10.14.0.0/16"

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
    resource_group_name = "alt-bca-web"
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

  alt_mpsql = {
    name                = "altsql"
    location_name       = "alt"
    resource_group_name = "alt-mpsql"
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
    resource_group_name = "primary-bca-web"
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

  primary_mpsql = {
    name                = "prmsql"
    location_name       = "primary"
    resource_group_name = "primary-mpsql"
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
    sku_size = "Standard_D2s_v3"

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
    vm_count = 2
    sku_size = "Standard_D2s_v3"

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }

  primary_mpsql = {
    vm_count = 3
    sku_size = "Standard_D2s_v3"

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
    sku_size = "Standard_D2s_v3"

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
