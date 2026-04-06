deployment_prefix = "lbt02"

locations = {
  main = "francecentral"
}

subscriptions = {
  main = {
    subscription_id             = "xxxx"
    default_resource_group_name = "main"
  }
}

resource_groups = {
  main = {
    name              = "main"
    location_name     = "main"
    subscription_name = "main"
  }
}

external_networks = {
  main = {
    address_space = "10.0.0.0/16"
    resource_id   = "/subscriptions/xxxx/resourceGroups/azri-testing-01/providers/Microsoft.Network/virtualNetworks/azritest01net"

    subnets = {
      default = {
        name          = "default"
        address_space = "10.0.0.0/24"
      }
    }
  }
}

networks = {
  app_vnet = {
    location_name       = "main"
    subscription_name   = "main"
    resource_group_name = "main"
    name                = "AppVNet"
    address_space       = "10.100.0.0/16"

    subnets = {
      web = {
        name                = "WebSubnet"
        address_space       = "10.100.0.0/24"
        security_group_name = "main"
      }

    }
  }
}

network_ports = {
  https = "443"
}

network_security_rules = {
  allow_https_in_to_main_vm_set = {
    protocol   = "Tcp"
    port_names = ["https"]
    allow      = { in = { to = { vm_set = { name = "main" } } } }
  }
}

network_security_groups = {
  main = {
    location_name       = "main"
    subscription_name   = "main"
    resource_group_name = "main"

    security_rules = [
      "allow_https_in_to_main_vm_set"
    ]
  }
}

virtual_machine_images = {
  windows_2022 = {
    reference = {
      offer     = "WindowsServer"
      publisher = "MicrosoftWindowsServer"
      sku       = "2022-datacenter-g2"
      version   = "latest"
    }
  }
}

virtual_machine_sets = {
  main = {
    name                = "main"
    image_name          = "windows_2022"
    key_vault_name      = "main"
    location_name       = "main"
    resource_group_name = "main"
    subscription_name   = "main"

    data_disk_groups = {
      data = {}
    }

    load_balancer = {
      nic_name = "main"

      internal_frontend = {
        network_name = "main"
        subnet_name  = "default"
      }

      health_probe = {
        protocol = "Tcp"
        port     = 443
      }

      rules = {
        https = {
          protocol      = "Tcp"
          frontend_port = 443
          backend_port  = 443
        }
      }
    }

    network_interfaces = {
      main = {
        network_name = "main"
        subnet_name  = "default"
      }
    }
  }
}

virtual_machine_set_specs = {
  main = {
    vm_count = 5
    sku_size = "Standard_D4as_v5"

    data_disk_groups = {
      data = {
        disk_count   = 3
        disk_size_gb = 128
      }
    }

    os_disk = {
      disk_size_gb = 128
    }
  }
}

key_vaults = {
  main = {
    location_name       = "main"
    subscription_name   = "main"
    resource_group_name = "main"
    sku_name            = "standard"
  }
}
