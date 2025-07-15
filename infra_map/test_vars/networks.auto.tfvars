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

network_security_rules = {
  allow_https_non_prod_to_prod = {
    allow = { in = {
      to = {
        vm_set = {
          vm_set_name = "non_production"
        }
      }
      from = {
        vm_set = {
          vm_set_name = "production"
        }
      }}
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

    security_rules = [
      "allow_https_non_prod_to_prod"
    ]

    subnets = {
      production = {
        address_space = "10.10.0.0/24"
        name          = "ProductionSubnet"
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
      }
    }
  }
}
