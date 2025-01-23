module "epic" {
  source = "../high_availability_virtual_machine_map"

  deployment_prefix = var.deployment_prefix

  tags = {
    epic-env = var.environment_name
  }

  locations = {
    alt     = var.locations.alt
    primary = var.locations.primary
  }

  networks = {
    primary_dmz = {
      location_name = "primary"
      name          = "${var.deployment_prefix}-${var.locations["primary"]}-dmz-net01"
      address_space = var.networks.primary.dmz.address_space

      subnets = {
        firewall = {
          name          = "FirewallSubnet"
          address_space = var.networks.primary.dmz.subnets.firewall.address_space
        }
        production = {
          address_space = var.networks.primary.dmz.subnets.production.address_space
        }
        non_production = {
          address_space = var.networks.primary.dmz.subnets.non_production.address_space
        }
      }
    }

    primary_shared_infra = {
      location_name = "primary"
      name          = "${var.deployment_prefix}-${var.locations["primary"]}-shared-infra-net01"
      address_space = var.networks.primary.shared_infra.address_space

      subnets = {
        gateway = {
          name          = "GatewaySubnet"
          address_space = var.networks.primary.shared_infra.subnets.gateway.address_space
        }
        management = {
          address_space = var.networks.primary.shared_infra.subnets.management.address_space
        }
      }

      peered_to = [
        "primary_hyperspace",
        "primary_hyperspace_web",
        "primary_main"
      ]
    }

    primary_main = {
      location_name = "primary"
      name          = "${var.deployment_prefix}-${var.locations["primary"]}-main-net01"
      address_space = var.networks.primary.main.address_space

      subnets = {
        cogito = {
          address_space = var.networks.primary.main.subnets.cogito.address_space
        }
        odb = {
          address_space = var.networks.primary.main.subnets.odb.address_space
        }
        wss = {
          address_space = var.networks.primary.main.subnets.wss.address_space
        }
      }

      peered_to = [
        "primary_hyperspace",
        "primary_hyperspace_web",
        "primary_shared_infra"
      ]
    }

    primary_hyperspace = {
      location_name = "primary"
      name          = "${var.deployment_prefix}-${var.locations["primary"]}-hyperspace-net01"
      address_space = var.networks.primary.hyperspace.address_space

      subnets = {
        hyperspace = {
          address_space = var.networks.primary.hyperspace.subnets.hyperspace.address_space
        }
      }

      peered_to = [
        "primary_hyperspace_web",
        "primary_main",
        "primary_shared_infra"
      ]
    }

    primary_hyperspace_web = {
      location_name = "primary"
      name          = "${var.deployment_prefix}-${var.locations["primary"]}-hyperspace-web-net01"
      address_space = var.networks.primary.hyperspace_web.address_space

      subnets = {
        hyperspace_web = {
          address_space = var.networks.primary.hyperspace_web.subnets.hyperspace_web.address_space
        }
      }

      peered_to = [
        "primary_hyperspace",
        "primary_main",
        "primary_shared_infra"
      ]
    }

    alt_dmz = {
      location_name = "alt"
      name          = "${var.deployment_prefix}-${var.locations["alt"]}-dmz-net01"
      address_space = var.networks.alt.dmz.address_space

      subnets = {
        firewall = {
          name          = "FirewallSubnet"
          address_space = var.networks.alt.dmz.subnets.firewall.address_space
        }
        production = {
          address_space = var.networks.alt.dmz.subnets.production.address_space
        }
        non_production = {
          address_space = var.networks.alt.dmz.subnets.non_production.address_space
        }
      }
    }

    alt_shared_infra = {
      location_name = "alt"
      name          = "${var.deployment_prefix}-${var.locations["alt"]}-shared-infra-net01"
      address_space = var.networks.alt.shared_infra.address_space

      subnets = {
        gateway = {
          name          = "GatewaySubnet"
          address_space = var.networks.alt.shared_infra.subnets.gateway.address_space
        }
        management = {
          address_space = var.networks.alt.shared_infra.subnets.management.address_space
        }
      }

      peered_to = [
        "alt_hyperspace",
        "alt_hyperspace_web",
        "alt_main"
      ]
    }

    alt_main = {
      location_name = "alt"
      name          = "${var.deployment_prefix}-${var.locations["alt"]}-main-net01"
      address_space = var.networks.alt.main.address_space

      subnets = {
        cogito = {
          address_space = var.networks.alt.main.subnets.cogito.address_space
        }
        odb = {
          address_space = var.networks.alt.main.subnets.odb.address_space
        }
        wss = {
          address_space = var.networks.alt.main.subnets.wss.address_space
        }
      }

      peered_to = [
        "alt_hyperspace",
        "alt_hyperspace_web",
        "alt_shared_infra"
      ]
    }

    alt_hyperspace = {
      location_name = "alt"
      name          = "${var.deployment_prefix}-${var.locations["alt"]}-hyperspace-net01"
      address_space = var.networks.alt.hyperspace.address_space

      subnets = {
        hyperspace = {
          address_space = var.networks.alt.hyperspace.subnets.hyperspace.address_space
        }
      }

      peered_to = [
        "alt_hyperspace_web",
        "alt_main",
        "alt_shared_infra"
      ]
    }

    alt_hyperspace_web = {
      location_name = "alt"
      name          = "${var.deployment_prefix}-${var.locations["alt"]}-hyperspace-web-net01"
      address_space = var.networks.alt.hyperspace_web.address_space

      subnets = {
        hyperspace_web = {
          address_space = var.networks.alt.hyperspace_web.subnets.hyperspace_web.address_space
        }
      }

      peered_to = [
        "alt_hyperspace",
        "alt_main",
        "alt_shared_infra"
      ]
    }
  }
}
