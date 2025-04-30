# These are the core Epic on Azure virtual networks and subnets as defined
# by the Epic on Azure reference architecture.
# Configure all address_spaces.
# Add additional networks and subnets as needed.

networks = {
  shared_dmz = {
    address_space          = "10.10.0.0/16"
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
        address_space = "10.10.0.0/24"
        name          = "FirewallSubnet"
      }

      production = {
        address_space = "10.10.1.0/24"
        name          = "ProductionSubnet"
      }

      non_production = {
        address_space = "10.10.2.0/24"
        name          = "NonProductionSubnet"
      }
    }
  }

  shared_infra = {
    address_space       = "10.20.0.0/16"
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
        address_space = "10.20.0.0/24"
        name          = "ManagementSubnet"
      }
    }
  }

  production = {
    address_space       = "10.30.0.0/16"
    name                = "production"
    location_name       = "production"
    resource_group_name = "networks"
    subscription_name   = "production"

    peered_to = [
      "shared_dmz",
      "shared_infra",
      "alt_production"
    ]

    subnets = {
      odb_cogito = {
        address_space = "10.30.0.0/24"
        name          = "ODBAndCogitoSubnet"
      }

      wss = {
        address_space = "10.30.1.0/24"
        name          = "WSSSubnet"
      }

      hyperspace = {
        address_space = "10.30.2.0/24"
        name          = "HyperspaceSubnet"
      }

      hyperspace_web = {
        address_space = "10.30.3.0/24"
        name          = "HyperspaceWebSubnet"
      }

      private_endpoints = {
        address_space = "10.30.4.0/24"
        name          = "PrivateEndpointsSubnet"
      }
    }
  }

  # Add more networks as your needs dictate.

  # alt_production = {
  #  address_space       = "10.100.0.0/16"
  #  name                = "alt-production"
  #  location_name       = "alt_production"
  #  resource_group_name = "alt_shared"
  #  subscription_name   = "alt_production"
  #
  #  peered_to = [
  #    "production"
  #  ]
  #
  #  subnets = {
  #    odb_cogito = {
  #      address_space = "10.100.0.0/24"
  #      name          = "ODBAndCogitoSubnet"
  #    }
  #  }
  # }
}
