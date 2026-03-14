module "infrastructure" {
  source = "../.."

  # =============================================================================
  # Core Configuration
  # =============================================================================
  deployment_prefix              = "prod"
  subscription_id                = "00000000-0000-0000-0000-000000000000"
  default_location_key_reference = "eastus"
  default_resource_group_key_reference = "shared"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Project     = "Infrastructure"
  }

  # =============================================================================
  # Locations (referenced by *_key_reference fields)
  # =============================================================================
  locations = {
    eastus  = "eastus"
    westus  = "westus2"
    central = "centralus"
  }

  # =============================================================================
  # Lock Groups (referenced by lock_groups_key_reference)
  # =============================================================================
  lock_groups = {
    production = {
      locked    = true
      read_only = false
    }
    development = {
      locked    = false
      read_only = false
    }
  }

  # =============================================================================
  # Resource Groups (referenced by resource_group_key_reference)
  # =============================================================================
  resource_groups = {
    shared = {
      location_key_reference    = "eastus"
      lock_groups_key_reference = ["production"]
    }
    network = {
      location_key_reference    = "eastus"
      lock_groups_key_reference = ["production"]
    }
    compute = {
      location_key_reference    = "eastus"
      lock_groups_key_reference = ["production"]
    }
    storage = {
      location_key_reference    = "eastus"
      lock_groups_key_reference = ["production"]
    }
  }

  # =============================================================================
  # Route Tables (referenced by route_table_key_reference in subnets)
  # =============================================================================
  route_tables = {
    default = {
      location_key_reference       = "eastus"
      resource_group_key_reference = "network"
      lock_groups_key_reference    = ["production"]
      routes = {
        to_firewall = {
          destined_for = {
            address_space = "0.0.0.0/0"
          }
          to_appliance = {
            ip_address = "10.0.0.4"
          }
        }
      }
    }
  }

  # =============================================================================
  # Network Ports (referenced by port_keys in network_security_rules)
  # =============================================================================
  network_ports = {
    https = "443"
    http  = "80"
    rdp   = "3389"
    ssh   = "22"
  }

  # =============================================================================
  # Network Security Rules (referenced by security_rules_key_reference in NSGs)
  # Uses allow/deny.in/out structure with from/to targeting address_space, network, subnet, or vm_set
  # =============================================================================
  network_security_rules = {
    # Allow HTTPS from anywhere to web tier
    allow_https_inbound = {
      protocol  = "Tcp"
      port_keys = ["https"]
      allow = {
        in = {
          to = {
            subnet = {
              network_key_reference = "spoke_app"
              subnet_key_reference  = "web"
            }
          }
        }
      }
    }

    # Allow RDP from bastion subnet to app tier
    allow_rdp_from_bastion = {
      protocol  = "Tcp"
      port_keys = ["rdp"]
      allow = {
        in = {
          from = {
            subnet = {
              network_key_reference = "hub"
              subnet_key_reference  = "bastion"
            }
          }
          to = {
            subnet = {
              network_key_reference = "spoke_app"
              subnet_key_reference  = "app"
            }
          }
        }
      }
    }

    # Allow web tier to talk to app tier
    allow_web_to_app = {
      protocol  = "Tcp"
      port_keys = ["https"]
      allow = {
        in = {
          from = {
            vm_set = {
              name = "web_servers"
            }
          }
          to = {
            vm_set = {
              name = "app_servers"
            }
          }
        }
      }
    }

    # Deny all inbound (catch-all)
    deny_all_inbound = {
      protocol = "*"
      deny = {
        in = {}
      }
    }
  }

  # =============================================================================
  # Network Security Groups (referenced by network_security_group_key_reference)
  # =============================================================================
  network_security_groups = {
    web_tier = {
      location_key_reference       = "eastus"
      resource_group_key_reference = "network"
      lock_groups_key_reference    = ["production"]
      security_rules_key_reference = ["allow_https_inbound", "deny_all_inbound"]
    }
    app_tier = {
      location_key_reference       = "eastus"
      resource_group_key_reference = "network"
      lock_groups_key_reference    = ["production"]
      security_rules_key_reference = ["allow_rdp_from_bastion", "allow_web_to_app", "deny_all_inbound"]
    }
  }

  # =============================================================================
  # Virtual Networks (referenced by network_key_reference)
  # =============================================================================
  virtual_networks = {
    hub = {
      location_key_reference       = "eastus"
      resource_group_key_reference = "network"
      lock_groups_key_reference    = ["production"]
      address_spaces               = ["10.0.0.0/16"]
      peered_to                    = ["spoke_app"]

      subnets = {
        firewall = {
          address_space = "10.0.0.0/26"
        }
        bastion = {
          address_space = "10.0.1.0/24"
        }
        gateway = {
          address_space = "10.0.2.0/24"
        }
      }
    }

    spoke_app = {
      location_key_reference       = "eastus"
      resource_group_key_reference = "network"
      lock_groups_key_reference    = ["production"]
      address_spaces               = ["10.1.0.0/16"]
      peered_to                    = ["hub"]

      subnets = {
        web = {
          address_space                        = "10.1.1.0/24"
          route_table_key_reference            = "default"
          network_security_group_key_reference = "web_tier"
        }
        app = {
          address_space                        = "10.1.2.0/24"
          route_table_key_reference            = "default"
          network_security_group_key_reference = "app_tier"
        }
        data = {
          address_space             = "10.1.3.0/24"
          route_table_key_reference = "default"
        }
        private_endpoints = {
          address_space             = "10.1.4.0/24"
          route_table_key_reference = "default"
        }
      }
    }
  }

  # =============================================================================
  # Private DNS Zones (referenced by private_dns_zone_key_references)
  # Set resource_group_key_reference to create a new zone, or resource_id_existing to use an existing one
  # =============================================================================
  private_dns_zones = {
    # Create a new zone
    blob = {
      domain_name                  = "privatelink.blob.core.windows.net"
      resource_group_key_reference = "network"
    }
    # Create a new zone
    vault = {
      domain_name                  = "privatelink.vaultcore.azure.net"
      resource_group_key_reference = "network"
    }
    # Example: Use an existing zone (uncomment to use)
    # sql = {
    #   domain_name          = "privatelink.database.windows.net"
    #   resource_id_existing = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net"
    # }
  }

  # Set to false to disable zone creation (only use existing zones via resource_id_existing)
  # private_dns_zones_create_enabled = false

  # =============================================================================
  # Storage Accounts (referenced by storage_account_key_reference)
  # =============================================================================
  storage_accounts = {
    data = {
      location_key_reference       = "eastus"
      resource_group_key_reference = "storage"
      lock_groups_key_reference    = ["production"]
      account_tier                 = "Standard"
      replication_type             = "ZRS"

      private_endpoints = {
        blob = {
          subresource_name              = "blob"
          network_key_reference         = "spoke_app"
          subnet_key_reference          = "private_endpoints"
          private_dns_zone_key_references = ["blob"]
        }
      }
    }
  }

  blob_containers = {
    logs = {
      storage_account_key_reference = "data"
      name                          = "logs"
    }
    backups = {
      storage_account_key_reference = "data"
      name                          = "backups"
    }
  }

  file_shares = {}

  # =============================================================================
  # Key Vaults (referenced by key_vault_key_reference)
  # =============================================================================
  key_vaults = {
    secrets = {
      location_key_reference       = "eastus"
      resource_group_key_reference = "shared"
      lock_groups_key_reference    = ["production"]
      sku_name                     = "standard"
      purge_protection_enabled     = true

      private_endpoints = {
        vault = {
          network_key_reference             = "spoke_app"
          subnet_key_reference              = "private_endpoints"
          private_dns_zone_key_references   = ["vault"]
        }
      }
    }
  }

  # =============================================================================
  # Virtual Machine Images (referenced by image_key_reference)
  # =============================================================================
  virtual_machine_images = {
    windows_2022 = {
      reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-azure-edition"
        version   = "latest"
      }
    }
    windows_2019 = {
      reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-datacenter"
        version   = "latest"
      }
    }
  }

  # =============================================================================
  # Virtual Machine Extensions (referenced by extensions_by_key_reference)
  # =============================================================================
  virtual_machine_extensions = {
    antimalware = {
      name                       = "IaaSAntimalware"
      publisher                  = "Microsoft.Azure.Security"
      type                       = "IaaSAntimalware"
      type_handler_version       = "1.3"
      auto_upgrade_minor_version = true
      settings = jsonencode({
        AntimalwareEnabled = true
        RealtimeProtectionEnabled = "true"
        ScheduledScanSettings = {
          isEnabled = "true"
          day       = "7"
          time      = "120"
          scanType  = "Quick"
        }
      })
    }
  }

  # =============================================================================
  # Shutdown Schedules (referenced by shutdown_schedule_key_reference)
  # =============================================================================
  virtual_machine_shutdown_schedules = {
    evening = {
      daily_recurrence_time = "1900"
      timezone              = "Eastern Standard Time"
      enabled               = true
    }
  }

  # =============================================================================
  # Maintenance Schedules (referenced by maintenance.schedule_key_reference)
  # =============================================================================
  maintenance_schedules = {
    weekly_sunday = {
      repeat_every = {
        week = true
      }
      start_date_time_utc = "2026-01-05 02:00"
      duration            = "2:00"
    }
  }

  # =============================================================================
  # Virtual Machine Sets (uses all key references)
  # =============================================================================
  virtual_machine_sets = {
    web_servers = {
      name                              = "web"
      include_deployment_prefix_in_name = true
      image_key_reference               = "windows_2022"
      key_vault_key_reference           = "secrets"
      location_key_reference            = "eastus"
      resource_group_key_reference      = "compute"
      lock_groups_key_reference         = ["production"]
      os_type                           = "Windows"
      deploy_scale_set                  = true
      enable_boot_diagnostics           = true
      extensions_by_key_reference       = ["antimalware"]
      shutdown_schedule_key_reference   = "evening"

      maintenance = {
        schedule_key_reference = "weekly_sunday"
      }

      network_interfaces = {
        primary = {
          network_key_reference         = "spoke_app"
          subnet_key_reference          = "web"
          enable_accelerated_networking = true
        }
      }

      data_disk_groups = {
        data = {
          caching = "ReadWrite"
        }
      }
    }

    app_servers = {
      name                              = "app"
      include_deployment_prefix_in_name = true
      image_key_reference               = "windows_2022"
      key_vault_key_reference           = "secrets"
      location_key_reference            = "eastus"
      resource_group_key_reference      = "compute"
      lock_groups_key_reference         = ["production"]
      os_type                           = "Windows"
      deploy_scale_set                  = true

      network_interfaces = {
        primary = {
          network_key_reference         = "spoke_app"
          subnet_key_reference          = "app"
          enable_accelerated_networking = true
        }
      }
    }
  }

  # =============================================================================
  # Virtual Machine Set Specs (keyed by virtual_machine_sets keys)
  # =============================================================================
  virtual_machine_set_specs = {
    web_servers = {
      sku_size = "Standard_D4s_v5"

      virtual_machines = {
        vm1 = { sequence_number = 1 }
        vm2 = { sequence_number = 2 }
      }

      os_disk = {
        disk_size_gb         = 128
        storage_account_type = "Premium_LRS"
      }

      data_disk_groups = {
        data = {
          disk_count   = 1
          disk_size_gb = 256
        }
      }
    }

    app_servers = {
      sku_size = "Standard_D8s_v5"

      virtual_machines = {
        vm1 = { sequence_number = 1 }
        vm2 = { sequence_number = 2 }
        vm3 = { sequence_number = 3 }
      }

      os_disk = {
        disk_size_gb         = 128
        storage_account_type = "Premium_LRS"
      }
    }
  }

  # =============================================================================
  # Zone Distribution (keyed by virtual_machine_sets keys)
  # =============================================================================
  virtual_machine_set_zone_distribution = {
    web_servers = {
      even = ["1", "2"]
    }
    app_servers = {
      even = ["1", "2", "3"]
    }
  }
}
