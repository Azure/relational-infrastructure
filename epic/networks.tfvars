networks = {
  shared_dmz = {
    address_space          = "10.100.0.0/16"
    name                   = "shared-dmz"
    location_name          = "production"
    resource_group_name    = "networks"
    subscription_name      = "production"
    enable_ddos_protection = true

    peered_to = [
      "shared_infra",
      "production"
    ]

    subnets = {
      firewall = {
        address_space = "10.100.0.0/24"
        name          = "FirewallSubnet"
      }

      production = {
        address_space = "10.100.1.0/24"
        name          = "ProductionSubnet"
      }

      non_production = {
        address_space = "10.100.2.0/24"
        name          = "NonProductionSubnet"
      }
    }

    shared_infra = {
      address_space       = "10.200.0.0/16"
      name                = "shared-infra"
      location_name       = "production"
      resource_group_name = "networks"
      subscription_name   = "production"

      peered_to = [
        "shared_dmz",
        "production"
      ]

      subnets = {
        management = {
          address_space = "10.200.0.0/24"
          name          = "ManagementSubnet"
        }
      }
    }

    production = {
      address_space       = "10.300.0.0/16"
      name                = "production"
      location_name       = "production"
      resource_group_name = "networks"
      subscription_name   = "production"

      peered_to = [
        "shared_dmz",
        "shared_infra"
      ]

      subnets = {
        odb_cogito = {
          address_space = "10.300.0.0/24"
          name          = "ODBAndCogitoSubnet"
        }

        wss = {
          address_space = "10.300.1.0/24"
          name          = "WSSSubnet"
        }

        hyperspace = {
          address_space = "10.300.2.0/24"
          name          = "HyperspaceSubnet"
        }

        hyperspace_web = {
          address_space = "10.300.3.0/24"
          name          = "HyperspaceWebSubnet"
        }
      }
    }
  }
}
