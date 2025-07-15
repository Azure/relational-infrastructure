external_networks = {
  external = {
    address_space = "10.100.0.0/16"
    resource_id   = "/subscriptions/00363a64-55c1-4807-92a4-7dfe011d5222/resourceGroups/external-networks/providers/Microsoft.Network/virtualNetworks/externalnetwork01"

    subnets = {
      default = {
        address_space = "10.100.0.0/24"
        name          = "default"
      }
    }
  }
}

network_ports = {
  http  = "80"
  https = "443"
  api   = "81"
}

network_security_rules = {
  deny_all_to_maintenance_subnet = {
    port_names = [
      "http",
      "https"
    ]

    deny = {
      in = {
        to = {
          subnet = {
            network_name = "production"
            subnet_name  = "maintenance"
          }
        }
      }
    }
  }

  allow_http_s_non_prod_to_prod = {
    port_names = [
      "http",
      "https"
    ]

    allow = {
      in = {
        to = {
          vm_set = {
            name = "production"
          }
        }
        from = {
          port_names = [
            "http",
            "https",
            "api"
          ]

          subnet = {
            network_name = "non_production"
            subnet_name  = "non_production"
          }
        }
      }
    }
  }

  allow_all_into_non_production_net = {
    port_names = [
      "http",
      "https"
    ]

    allow = {
      in = {
        to = {
          network = {
            name = "non_production"
          }
        }
      }
    }
  }
}

networks = {
  production = {
    address_space       = "10.10.0.0/16"
    name                = "production"
    location_name       = "shared"
    resource_group_name = "shared"
    subscription_name   = "shared"

    private_dns_zones = {
      resolution_zone_names = [
        "key_vault_private_endpoints"
      ]
    }

    subnets = {
      production = {
        address_space = "10.10.0.0/24"
        name          = "ProductionSubnet"

        security_rules = [
          "allow_http_s_non_prod_to_prod",
          "deny_all_to_maintenance_subnet"
        ]
      }

      maintenance = {
        address_space = "10.10.1.0/24"
        name          = "MaintenanceSubnet"
      }
    }
  }

  non_production = {
    address_spaces = [
      "10.20.0.0/16",
      "10.30.0.0/16"
    ]

    name                = "non-production"
    location_name       = "shared"
    resource_group_name = "shared"
    subscription_name   = "shared"

    peered_to = [
      "production"
    ]

    subnets = {
      maintenance = {
        address_space = "10.20.0.0/24"
        name          = "MaintenanceSubnet"
      }

      non_production = {
        address_space = "10.30.0.0/24"
        name          = "NonProductionSubnet"

        security_rules = [
          "allow_all_into_non_production_net"
        ]
      }
    }
  }
}
