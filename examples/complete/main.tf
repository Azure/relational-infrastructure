module "infrastructure" {
  source = "../.."

  # =============================================================================
  # Core Configuration
  # =============================================================================
  deployment_prefix              = "prod"
  subscription_id                = "d6a7c15c-738d-4770-84c4-5f3b4952e35f"
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
  # Health Probes (referenced by health_probe_key_reference in load_balancer_rules)
  # =============================================================================
  health_probes = {
    https_health = {
      protocol     = "Https"
      port_key     = "https"
      request_path = "/health"
    }
    http_health = {
      protocol     = "Http"
      port_key     = "http"
      request_path = "/health"
    }
    https_api_health = {
      protocol     = "Https"
      port_key     = "https"
      request_path = "/api/health"
    }
    tcp_https = {
      protocol = "Tcp"
      port_key = "https"
    }
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
          nat_gateway_key_reference            = "app_natgw"
        }
        data = {
          address_space                 = "10.1.3.0/24"
          route_table_key_reference     = "default"
          nat_gateway_key_reference     = "app_natgw"
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

          # Join web servers to external load balancer backend pool
          load_balancer_backend_pools = [
            {
              load_balancer_key_reference = "web_external_lb"
              backend_pool_key_reference  = "web_pool"
            }
          ]
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

          # Join app servers to internal load balancer backend pool
          load_balancer_backend_pools = [
            {
              load_balancer_key_reference = "app_internal_lb"
              backend_pool_key_reference  = "app_pool"
            }
          ]
        }
      }
    }
  }

  # =============================================================================
  # Public IP Configurations (referenced by public_ip_key_reference)
  # =============================================================================
  public_ip_configurations = {
    # For load balancers - DDoS protection auto-determined, uses Standard SKU
    standard_zone_redundant = {
      allocation_method = "Static"
      sku               = "Standard"
      sku_tier          = "Regional"
      zones             = ["1", "2", "3"]
    }

    # For NAT Gateways - DDoS protection must be disabled/inherited, requires StandardV2 for NAT Gateway StandardV2
    natgw_pip_v2 = {
      allocation_method    = "Static"
      ddos_protection_mode = "VirtualNetworkInherited" # NAT Gateway does not support DDoS protection
      sku                  = "StandardV2"              # Required for NAT Gateway StandardV2 SKU
      sku_tier             = "Regional"
      zones                = ["1", "2", "3"]
    }
  }

  # =============================================================================
  # Load Balancers
  # =============================================================================
  load_balancers = {
    # External load balancer for web tier
    web_external_lb = {
      location_key_reference       = "eastus"
      resource_group_key_reference = "network"
      lock_groups_key_reference    = ["production"]
      type                         = "external"

      frontend_ip_configurations = {
        web_frontend = {
          public_ip_key_reference = "standard_zone_redundant"
        }
      }

      backend_pools = {
        web_pool = {}
      }
    }

    # Internal load balancer for app tier
    app_internal_lb = {
      location_key_reference       = "eastus"
      resource_group_key_reference = "network"
      lock_groups_key_reference    = ["production"]
      type                         = "internal"

      frontend_ip_configurations = {
        app_frontend = {
          network_key_reference = "spoke_app"
          subnet_key_reference  = "app"
          private_ip_allocation = "Dynamic"
          zones                 = ["1", "2", "3"]
        }
      }

      backend_pools = {
        app_pool = {}
      }
    }
  }

  # =============================================================================
  # Load Balancer Rules (uses network_ports and health_probes references)
  # =============================================================================
  load_balancer_rules = {
    # HTTPS rule for web load balancer
    web_https_rule = {
      load_balancer_key_reference = "web_external_lb"
      frontend_key_reference      = "web_frontend"
      backend_pool_key_reference  = "web_pool"
      protocol                    = "Tcp"
      frontend_port_key           = "https"
      backend_port_key            = "https"
      health_probe_key_reference  = "https_health"
    }

    # HTTP rule for web load balancer
    web_http_rule = {
      load_balancer_key_reference = "web_external_lb"
      frontend_key_reference      = "web_frontend"
      backend_pool_key_reference  = "web_pool"
      protocol                    = "Tcp"
      frontend_port_key           = "http"
      backend_port_key            = "http"
      health_probe_key_reference  = "http_health"
    }

    # HTTPS rule for app load balancer
    app_https_rule = {
      load_balancer_key_reference = "app_internal_lb"
      frontend_key_reference      = "app_frontend"
      backend_pool_key_reference  = "app_pool"
      protocol                    = "Tcp"
      frontend_port_key           = "https"
      backend_port_key            = "https"
      health_probe_key_reference  = "https_api_health"
    }
  }

  # =============================================================================
  # NAT Gateways
  # Provides outbound connectivity for private subnets
  # Public IPs use public_ip_configurations (must have DDoS protection disabled)
  # =============================================================================
  nat_gateways = {
    # NAT Gateway v2 for app tier outbound connectivity
    app_natgw = {
      location_key_reference       = "eastus"
      resource_group_key_reference = "network"
      lock_groups_key_reference    = ["production"]
      sku_name                     = "StandardV2"
      idle_timeout_in_minutes      = 10

      # Create public IPs for this NAT Gateway
      public_ips = {
        pip1 = {
          public_ip_key_reference = "natgw_pip_v2"
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
