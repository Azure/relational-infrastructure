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
    primary_arr = try(var.workloads.primary.client.arr, null) == null ? null : {
      name                          = "${local.primary_location_prefix}arr"
      resource_group_name           = "${local.primary_location}-arr"
      image                         = var.workloads.primary.client.arr.image
      capacity_reservation_group_id = var.workloads.primary.client.arr.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.arr.data_disks
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

    primary_bca_pc = try(var.workloads.primary.client.bca_pc, null) == null ? null : {
      name                          = "${local.primary_location_prefix}bcp"
      resource_group_name           = "${local.primary_location}-bca-pc"
      image                         = var.workloads.primary.client.bca_pc.image
      capacity_reservation_group_id = var.workloads.primary.client.bca_pc.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.bca_pc.data_disks
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

    primary_bca_web = try(var.workloads.primary.client.bca_web, null) == null ? null : {
      name                          = "${local.primary_location_prefix}bcw"
      resource_group_name           = "${local.primary_location}-bca-web"
      image                         = var.workloads.primary.client.bca_web.image
      capacity_reservation_group_id = var.workloads.primary.client.bca_web.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.bca_web.data_disks
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

    primary_care_everywhere = try(var.workloads.primary.client.care_everywhere, null) == null ? null : {
      name                          = "${local.primary_location_prefix}cev"
      resource_group_name           = "${local.primary_location}-care-everywhere"
      image                         = var.workloads.primary.client.care_everywhere.image
      capacity_reservation_group_id = var.workloads.primary.client.care_everywhere.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.care_everywhere.data_disks
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

    primary_care_everywhere_arr = try(var.workloads.primary.client.care_everywhere_arr, null) == null ? null : {
      name                          = "${local.primary_location_prefix}car"
      resource_group_name           = "${local.primary_location}-care-everywhere-arr"
      image                         = var.workloads.primary.client.care_everywhere_arr.image
      capacity_reservation_group_id = var.workloads.primary.client.care_everywhere_arr.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.care_everywhere_arr.data_disks
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

    primary_digital_signing = try(var.workloads.primary.client.digital_signing, null) == null ? null : {
      name                          = "${local.primary_location_prefix}dss"
      resource_group_name           = "${local.primary_location}-dss"
      image                         = var.workloads.primary.client.digital_signing.image
      capacity_reservation_group_id = var.workloads.primary.client.digital_signing.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.digital_signing.data_disks
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

    primary_epiccare_link = try(var.workloads.primary.client.epiccare_link, null) == null ? null : {
      name                          = "${local.primary_location_prefix}ecl"
      resource_group_name           = "${local.primary_location}-epiccare-link"
      image                         = var.workloads.primary.client.epiccare_link.image
      capacity_reservation_group_id = var.workloads.primary.client.epiccare_link.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.epiccare_link.data_disks
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

    primary_hyperspace_web = try(var.workloads.primary.client.hyperspace_web, null) == null ? null : {
      name                          = "${local.primary_location_prefix}hsw"
      resource_group_name           = "${local.primary_location}-hyperspace-web"
      image                         = var.workloads.primary.client.hyperspace_web.image
      capacity_reservation_group_id = var.workloads.primary.client.hyperspace_web.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.hyperspace_web.data_disks
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

    primary_interconnect = try(var.workloads.primary.client.interconnect, null) == null ? null : {
      name                          = "${local.primary_location_prefix}icn"
      resource_group_name           = "${local.primary_location}-interconnect"
      image                         = var.workloads.primary.client.interconnect.image
      capacity_reservation_group_id = var.workloads.primary.client.interconnect.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.interconnect.data_disks
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

    primary_mpsql = try(var.workloads.primary.client.mpsql, null) == null ? null : {
      name                          = "${local.primary_location_prefix}sql"
      resource_group_name           = "${local.primary_location}-mpsql"
      image                         = var.workloads.primary.client.mpsql.image
      capacity_reservation_group_id = var.workloads.primary.client.mpsql.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.mpsql.data_disks
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
        cluster = {
          network_name = "primary_shared_infra"
          subnet_name  = "management"
        }
      }
    }

    primary_system_pulse = try(var.workloads.primary.client.system_pulse, null) == null ? null : {
      name                          = "${local.primary_location_prefix}sps"
      resource_group_name           = "${local.primary_location}-system-pulse"
      image                         = var.workloads.primary.client.system_pulse.image
      capacity_reservation_group_id = var.workloads.primary.client.system_pulse.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.system_pulse.data_disks
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

    primary_web_blob = try(var.workloads.primary.client.web_blob, null) == null ? null : {
      name                          = "${local.primary_location_prefix}wbs"
      resource_group_name           = "${local.primary_location}-web-blob"
      image                         = var.workloads.primary.client.web_blob.image
      capacity_reservation_group_id = var.workloads.primary.client.web_blob.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.web_blob.data_disks
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

    primary_eps = try(var.workloads.primary.client.eps, null) == null ? null : {
      name                          = "${local.primary_location_prefix}eps"
      resource_group_name           = "${local.primary_location}-eps"
      image                         = var.workloads.primary.client.eps.image
      capacity_reservation_group_id = var.workloads.primary.client.eps.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.eps.data_disks
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

    primary_kuiper = try(var.workloads.primary.client.kuiper, null) == null ? null : {
      name                          = "${local.primary_location_prefix}kpr"
      resource_group_name           = "${local.primary_location}-kuiper"
      image                         = var.workloads.primary.client.kuiper.image
      capacity_reservation_group_id = var.workloads.primary.client.kuiper.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.kuiper.data_disks
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

    primary_mychart = try(var.workloads.primary.client.mychart, null) == null ? null : {
      name                          = "${local.primary_location_prefix}myc"
      resource_group_name           = "${local.primary_location}-mychart"
      image                         = var.workloads.primary.client.mychart.image
      capacity_reservation_group_id = var.workloads.primary.client.mychart.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.mychart.data_disks
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

    primary_sts = try(var.workloads.primary.client.sts, null) == null ? null : {
      name                          = "${local.primary_location_prefix}adc"
      resource_group_name           = "${local.primary_location}-domain-controllers"
      image                         = var.workloads.primary.client.sts.image
      capacity_reservation_group_id = var.workloads.primary.client.sts.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.sts.data_disks
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

    primary_citrix_cc = try(var.workloads.primary.client.citrix_cc, null) == null ? null : {
      name                          = "${local.primary_location_prefix}ccc"
      resource_group_name           = "${local.primary_location}-citrix-cc"
      image                         = var.workloads.primary.client.citrix_cc.image
      capacity_reservation_group_id = var.workloads.primary.client.citrix_cc.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.citrix_cc.data_disks
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

    primary_willow = try(var.workloads.primary.client.willow, null) == null ? null : {
      name                          = "${local.primary_location_prefix}wlw"
      resource_group_name           = "${local.primary_location}-willow"
      image                         = var.workloads.primary.client.willow.image
      capacity_reservation_group_id = var.workloads.primary.client.willow.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.willow.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "willow"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "wss"
        }
      }
    }

    primary_image_exchange = try(var.workloads.primary.client.image_exchange, null) == null ? null : {
      name                          = "${local.primary_location_prefix}imx"
      resource_group_name           = "${local.primary_location}-image-exchange"
      image                         = var.workloads.primary.client.image_exchange.image
      capacity_reservation_group_id = var.workloads.primary.client.image_exchange.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.client.image_exchange.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "imageexchange"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "wss"
        }
      }
    }

    alt_arr = try(var.workloads.alt.client.arr, null) == null ? null : {
      name                          = "${local.alt_location_prefix}arr"
      resource_group_name           = "${local.alt_location}-arr"
      image                         = var.workloads.alt.client.arr.image
      capacity_reservation_group_id = var.workloads.alt.client.arr.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.arr.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "arr"
      }

      network_interfaces = {
        default = {
          network_name = "alt_dmz"
          subnet_name  = "production"
        }
      }
    }

    alt_bca_pc = try(var.workloads.alt.client.bca_pc, null) == null ? null : {
      name                          = "${local.alt_location_prefix}bcp"
      resource_group_name           = "${local.alt_location}-bca-pc"
      image                         = var.workloads.alt.client.bca_pc.image
      capacity_reservation_group_id = var.workloads.alt.client.bca_pc.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.bca_pc.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "bca"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "wss"
        }
      }
    }

    alt_bca_web = try(var.workloads.alt.client.bca_web, null) == null ? null : {
      name                          = "${local.alt_location_prefix}bcw"
      resource_group_name           = "${local.alt_location}-bca-web"
      image                         = var.workloads.alt.client.bca_web.image
      capacity_reservation_group_id = var.workloads.alt.client.bca_web.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.bca_web.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "bcaweb"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "wss"
        }
      }
    }

    alt_care_everywhere = try(var.workloads.alt.client.care_everywhere, null) == null ? null : {
      name                          = "${local.alt_location_prefix}cev"
      resource_group_name           = "${local.alt_location}-care-everywhere"
      image                         = var.workloads.alt.client.care_everywhere.image
      capacity_reservation_group_id = var.workloads.alt.client.care_everywhere.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.care_everywhere.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "careeverywhere"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "wss"
        }
      }
    }

    alt_care_everywhere_arr = try(var.workloads.alt.client.care_everywhere_arr, null) == null ? null : {
      name                          = "${local.alt_location_prefix}car"
      resource_group_name           = "${local.alt_location}-care-everywhere-arr"
      image                         = var.workloads.alt.client.care_everywhere_arr.image
      capacity_reservation_group_id = var.workloads.alt.client.care_everywhere_arr.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.care_everywhere_arr.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "careeverywherearr"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "wss"
        }
      }
    }

    alt_digital_signing = try(var.workloads.alt.client.digital_signing, null) == null ? null : {
      name                          = "${local.alt_location_prefix}dss"
      resource_group_name           = "${local.alt_location}-dss"
      image                         = var.workloads.alt.client.digital_signing.image
      capacity_reservation_group_id = var.workloads.alt.client.digital_signing.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.digital_signing.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "dss"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "wss"
        }
      }
    }

    alt_epiccare_link = try(var.workloads.alt.client.epiccare_link, null) == null ? null : {
      name                          = "${local.alt_location_prefix}ecl"
      resource_group_name           = "${local.alt_location}-epiccare-link"
      image                         = var.workloads.alt.client.epiccare_link.image
      capacity_reservation_group_id = var.workloads.alt.client.epiccare_link.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.epiccare_link.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "ecl"
      }

      network_interfaces = {
        default = {
          network_name = "alt_dmz"
          subnet_name  = "production"
        }
      }
    }

    alt_hyperspace_web = try(var.workloads.alt.client.hyperspace_web, null) == null ? null : {
      name                          = "${local.alt_location_prefix}hsw"
      resource_group_name           = "${local.alt_location}-hyperspace-web"
      image                         = var.workloads.alt.client.hyperspace_web.image
      capacity_reservation_group_id = var.workloads.alt.client.hyperspace_web.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.hyperspace_web.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "hsw"
      }

      network_interfaces = {
        default = {
          network_name = "alt_hyperspace_web"
          subnet_name  = "hyperspace_web"
        }
      }
    }

    alt_interconnect = try(var.workloads.alt.client.interconnect, null) == null ? null : {
      name                          = "${local.alt_location_prefix}icn"
      resource_group_name           = "${local.alt_location}-interconnect"
      image                         = var.workloads.alt.client.interconnect.image
      capacity_reservation_group_id = var.workloads.alt.client.interconnect.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.interconnect.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "interconnect"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "wss"
        }
      }
    }

    alt_mpsql = try(var.workloads.alt.client.mpsql, null) == null ? null : {
      name                          = "${local.alt_location_prefix}sql"
      resource_group_name           = "${local.alt_location}-mpsql"
      image                         = var.workloads.alt.client.mpsql.image
      capacity_reservation_group_id = var.workloads.alt.client.mpsql.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.mpsql.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "mpsql"
      }

      network_interfaces = {
        default = {
          network_name = "alt_shared_infra"
          subnet_name  = "management"
        }
        cluster = {
          network_name = "alt_shared_infra"
          subnet_name  = "management"
        }
      }
    }

    alt_system_pulse = try(var.workloads.alt.client.system_pulse, null) == null ? null : {
      name                          = "${local.alt_location_prefix}sps"
      resource_group_name           = "${local.alt_location}-system-pulse"
      image                         = var.workloads.alt.client.system_pulse.image
      capacity_reservation_group_id = var.workloads.alt.client.system_pulse.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.system_pulse.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "systempulse"
      }

      network_interfaces = {
        default = {
          network_name = "alt_shared_infra"
          subnet_name  = "management"
        }
      }
    }

    alt_web_blob = try(var.workloads.alt.client.web_blob, null) == null ? null : {
      name                          = "${local.alt_location_prefix}wbs"
      resource_group_name           = "${local.alt_location}-web-blob"
      image                         = var.workloads.alt.client.web_blob.image
      capacity_reservation_group_id = var.workloads.alt.client.web_blob.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.web_blob.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "wbs"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "wss"
        }
      }
    }

    alt_eps = try(var.workloads.alt.client.eps, null) == null ? null : {
      name                          = "${local.alt_location_prefix}eps"
      resource_group_name           = "${local.alt_location}-eps"
      image                         = var.workloads.alt.client.eps.image
      capacity_reservation_group_id = var.workloads.alt.client.eps.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.eps.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "eps"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "wss"
        }
      }
    }

    alt_kuiper = try(var.workloads.alt.client.kuiper, null) == null ? null : {
      name                          = "${local.alt_location_prefix}kpr"
      resource_group_name           = "${local.alt_location}-kuiper"
      image                         = var.workloads.alt.client.kuiper.image
      capacity_reservation_group_id = var.workloads.alt.client.kuiper.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.kuiper.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "kuiper"
      }

      network_interfaces = {
        default = {
          network_name = "alt_shared_infra"
          subnet_name  = "management"
        }
      }
    }

    alt_mychart = try(var.workloads.alt.client.mychart, null) == null ? null : {
      name                          = "${local.alt_location_prefix}myc"
      resource_group_name           = "${local.alt_location}-mychart"
      image                         = var.workloads.alt.client.mychart.image
      capacity_reservation_group_id = var.workloads.alt.client.mychart.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.mychart.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "mychart"
      }

      network_interfaces = {
        default = {
          network_name = "alt_dmz"
          subnet_name  = "production"
        }
      }
    }

    alt_sts = try(var.workloads.alt.client.sts, null) == null ? null : {
      name                          = "${local.alt_location_prefix}adc"
      resource_group_name           = "${local.alt_location}-domain-controllers"
      image                         = var.workloads.alt.client.sts.image
      capacity_reservation_group_id = var.workloads.alt.client.sts.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.sts.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "sts"
      }

      network_interfaces = {
        default = {
          network_name = "alt_shared_infra"
          subnet_name  = "management"
        }
      }
    }

    alt_citrix_cc = try(var.workloads.alt.client.citrix_cc, null) == null ? null : {
      name                          = "${local.alt_location_prefix}ccc"
      resource_group_name           = "${local.alt_location}-citrix-cc"
      image                         = var.workloads.alt.client.citrix_cc.image
      capacity_reservation_group_id = var.workloads.alt.client.citrix_cc.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.citrix_cc.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "citrix-cc"
      }

      network_interfaces = {
        default = {
          network_name = "alt_shared_infra"
          subnet_name  = "management"
        }
      }
    }

    alt_willow = try(var.workloads.alt.client.willow, null) == null ? null : {
      name                          = "${local.alt_location_prefix}wlw"
      resource_group_name           = "${local.alt_location}-willow"
      image                         = var.workloads.alt.client.willow.image
      capacity_reservation_group_id = var.workloads.alt.client.willow.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.willow.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "willow"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "wss"
        }
      }
    }

    alt_image_exchange = try(var.workloads.alt.client.image_exchange, null) == null ? null : {
      name                          = "${local.alt_location_prefix}imx"
      resource_group_name           = "${local.alt_location}-image-exchange"
      image                         = var.workloads.alt.client.image_exchange.image
      capacity_reservation_group_id = var.workloads.alt.client.image_exchange.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.client.image_exchange.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "imageexchange"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "wss"
        }
      }
    }
  }

  virtual_machine_set_specs = {
    primary_arr                 = var.workload_specs.primary.client.arr
    primary_bca_pc              = var.workload_specs.primary.client.bca_pc
    primary_bca_web             = var.workload_specs.primary.client.bca_web
    primary_care_everywhere     = var.workload_specs.primary.client.care_everywhere
    primary_care_everywhere_arr = var.workload_specs.primary.client.care_everywhere_arr
    primary_digital_signing     = var.workload_specs.primary.client.digital_signing
    primary_epiccare_link       = var.workload_specs.primary.client.epiccare_link
    primary_hyperspace_web      = var.workload_specs.primary.client.hyperspace_web
    primary_interconnect        = var.workload_specs.primary.client.interconnect
    primary_mpsql               = var.workload_specs.primary.client.mpsql
    primary_system_pulse        = var.workload_specs.primary.client.system_pulse
    primary_web_blob            = var.workload_specs.primary.client.web_blob
    primary_eps                 = var.workload_specs.primary.client.eps
    primary_kuiper              = var.workload_specs.primary.client.kuiper
    primary_mychart             = var.workload_specs.primary.client.mychart
    primary_sts                 = var.workload_specs.primary.client.sts
    primary_citrix_cc           = var.workload_specs.primary.client.citrix_cc
    primary_willow              = var.workload_specs.primary.client.willow
    primary_image_exchange      = var.workload_specs.primary.client.image_exchange

    alt_arr                 = var.workload_specs.alt.client.arr
    alt_bca_pc              = var.workload_specs.alt.client.bca_pc
    alt_bca_web             = var.workload_specs.alt.client.bca_web
    alt_care_everywhere     = var.workload_specs.alt.client.care_everywhere
    alt_care_everywhere_arr = var.workload_specs.alt.client.care_everywhere_arr
    alt_digital_signing     = var.workload_specs.alt.client.digital_signing
    alt_epiccare_link       = var.workload_specs.alt.client.epiccare_link
    alt_hyperspace_web      = var.workload_specs.alt.client.hyperspace_web
    alt_interconnect        = var.workload_specs.alt.client.interconnect
    alt_mpsql               = var.workload_specs.alt.client.mpsql
    alt_system_pulse        = var.workload_specs.alt.client.system_pulse
    alt_web_blob            = var.workload_specs.alt.client.web_blob
    alt_eps                 = var.workload_specs.alt.client.eps
    alt_kuiper              = var.workload_specs.alt.client.kuiper
    alt_mychart             = var.workload_specs.alt.client.mychart
    alt_sts                 = var.workload_specs.alt.client.sts
    alt_citrix_cc           = var.workload_specs.alt.client.citrix_cc
    alt_willow              = var.workload_specs.alt.client.willow
    alt_image_exchange      = var.workload_specs.alt.client.image_exchange
  }
}
