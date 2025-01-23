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

  virtual_machine_sets = {
    primary_arr = try(var.virtual_machine_sets.primary.arr, null) == null ? null : {
      name                          = "${local.primary_location_prefix}arr"
      resource_group_name           = "${local.primary_location}-arr"
      image                         = var.virtual_machine_sets.primary.arr.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.arr.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.arr.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "arr"
      }

      network_interfaces = {
        default = {
          network_name = "primary_dmz"
          subnet_name  = "production"
        }
      }
    }

    primary_bca_pc = try(var.virtual_machine_sets.primary.bca_pc, null) == null ? null : {
      name                          = "${local.primary_location_prefix}bcp"
      resource_group_name           = "${local.primary_location}-bca-pc"
      image                         = var.virtual_machine_sets.primary.bca_pc.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.bca_pc.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.bca_pc.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "bca"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "wss"
        }
      }
    }

    primary_bca_web = try(var.virtual_machine_sets.primary.bca_web, null) == null ? null : {
      name                          = "${local.primary_location_prefix}bcw"
      resource_group_name           = "${local.primary_location}-bca-web"
      image                         = var.virtual_machine_sets.primary.bca_web.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.bca_web.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.bca_web.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "bcaweb"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "wss"
        }
      }
    }

    primary_care_everywhere = try(var.virtual_machine_sets.primary.care_everywhere, null) == null ? null : {
      name                          = "${local.primary_location_prefix}cev"
      resource_group_name           = "${local.primary_location}-care-everywhere"
      image                         = var.virtual_machine_sets.primary.care_everywhere.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.care_everywhere.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.care_everywhere.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "careeverywhere"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "wss"
        }
      }
    }

    primary_care_everywhere_arr = try(var.virtual_machine_sets.primary.care_everywhere_arr, null) == null ? null : {
      name                          = "${local.primary_location_prefix}car"
      resource_group_name           = "${local.primary_location}-care-everywhere-arr"
      image                         = var.virtual_machine_sets.primary.care_everywhere_arr.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.care_everywhere_arr.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.care_everywhere_arr.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "careeverywherearr"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "wss"
        }
      }
    }

    primary_digital_signing = try(var.virtual_machine_sets.primary.digital_signing, null) == null ? null : {
      name                          = "${local.primary_location_prefix}dss"
      resource_group_name           = "${local.primary_location}-dss"
      image                         = var.virtual_machine_sets.primary.digital_signing.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.digital_signing.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.digital_signing.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "dss"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "wss"
        }
      }
    }

    primary_epiccare_link = try(var.virtual_machine_sets.primary.epiccare_link, null) == null ? null : {
      name                          = "${local.primary_location_prefix}ecl"
      resource_group_name           = "${local.primary_location}-epiccare-link"
      image                         = var.virtual_machine_sets.primary.epiccare_link.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.epiccare_link.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.epiccare_link.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "ecl"
      }

      network_interfaces = {
        default = {
          network_name = "primary_dmz"
          subnet_name  = "production"
        }
      }
    }

    primary_hyperspace_web = try(var.virtual_machine_sets.primary.hyperspace_web, null) == null ? null : {
      name                          = "${local.primary_location_prefix}hsw"
      resource_group_name           = "${local.primary_location}-hyperspace-web"
      image                         = var.virtual_machine_sets.primary.hyperspace_web.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.hyperspace_web.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.hyperspace_web.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "hsw"
      }

      network_interfaces = {
        default = {
          network_name = "primary_hyperspace_web"
          subnet_name  = "hyperspace_web"
        }
      }
    }

    primary_interconnect = try(var.virtual_machine_sets.primary.interconnect, null) == null ? null : {
      name                          = "${local.primary_location_prefix}icn"
      resource_group_name           = "${local.primary_location}-interconnect"
      image                         = var.virtual_machine_sets.primary.interconnect.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.interconnect.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.interconnect.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "interconnect"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "wss"
        }
      }
    }

    primary_mpsql = try(var.virtual_machine_sets.primary.mpsql, null) == null ? null : {
      name                          = "${local.primary_location_prefix}sql"
      resource_group_name           = "${local.primary_location}-mpsql"
      image                         = var.virtual_machine_sets.primary.mpsql.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.mpsql.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.mpsql.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "mpsql"
      }

      network_interfaces = {
        default = {
          network_name = "primary_shared_infra"
          subnet_name  = "management"
        }
      }
    }

    primary_system_pulse = try(var.virtual_machine_sets.primary.system_pulse, null) == null ? null : {
      name                          = "${local.primary_location_prefix}sps"
      resource_group_name           = "${local.primary_location}-system-pulse"
      image                         = var.virtual_machine_sets.primary.system_pulse.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.system_pulse.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.system_pulse.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "systempulse"
      }

      network_interfaces = {
        default = {
          network_name = "primary_shared_infra"
          subnet_name  = "management"
        }
      }
    }

    primary_web_blob = try(var.virtual_machine_sets.primary.web_blob, null) == null ? null : {
      name                          = "${local.primary_location_prefix}wbs"
      resource_group_name           = "${local.primary_location}-web-blob"
      image                         = var.virtual_machine_sets.primary.web_blob.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.web_blob.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.web_blob.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "wbs"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "wss"
        }
      }
    }

    primary_eps = try(var.virtual_machine_sets.primary.eps, null) == null ? null : {
      name                          = "${local.primary_location_prefix}eps"
      resource_group_name           = "${local.primary_location}-eps"
      image                         = var.virtual_machine_sets.primary.eps.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.eps.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.eps.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "eps"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "wss"
        }
      }
    }

    primary_kuiper = try(var.virtual_machine_sets.primary.kuiper, null) == null ? null : {
      name                          = "${local.primary_location_prefix}kpr"
      resource_group_name           = "${local.primary_location}-kuiper"
      image                         = var.virtual_machine_sets.primary.kuiper.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.kuiper.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.kuiper.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "kuiper"
      }

      network_interfaces = {
        default = {
          network_name = "primary_shared_infra"
          subnet_name  = "management"
        }
      }
    }

    primary_mychart = try(var.virtual_machine_sets.primary.mychart, null) == null ? null : {
      name                          = "${local.primary_location_prefix}myc"
      resource_group_name           = "${local.primary_location}-mychart"
      image                         = var.virtual_machine_sets.primary.mychart.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.mychart.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.mychart.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "mychart"
      }

      network_interfaces = {
        default = {
          network_name = "primary_dmz"
          subnet_name  = "production"
        }
      }
    }

    primary_sts = try(var.virtual_machine_sets.primary.sts, null) == null ? null : {
      name                          = "${local.primary_location_prefix}adc"
      resource_group_name           = "${local.primary_location}-domain-controllers"
      image                         = var.virtual_machine_sets.primary.sts.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.sts.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.sts.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "sts"
      }

      network_interfaces = {
        default = {
          network_name = "primary_shared_infra"
          subnet_name  = "management"
        }
      }
    }

    primary_citrix_cc = try(var.virtual_machine_sets.primary.citrix_cc, null) == null ? null : {
      name                          = "${local.primary_location_prefix}ccc"
      resource_group_name           = "${local.primary_location}-citrix-cc"
      image                         = var.virtual_machine_sets.primary.citrix_cc.image
      capacity_reservation_group_id = var.virtual_machine_sets.primary.citrix_cc.capacity_reservation_group_id
      data_disks                    = var.virtual_machine_sets.primary.citrix_cc.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "citrix-cc"
      }

      network_interfaces = {
        default = {
          network_name = "primary_shared_infra"
          subnet_name  = "management"
        }
      }
    }
  }

  virtual_machine_set_specs = {

  }
}
