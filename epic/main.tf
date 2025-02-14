module "epic" {
  source = "../high_availability_virtual_machine_map"

  ddos_protection_plan_name = var.ddos_protection_plan_name
  deployment_prefix         = var.deployment_prefix
  enable_automatic_updates  = var.enable_automatic_updates
  include_label_tags        = var.include_label_tags

  tags = {
    epic-env = var.environment_name
  }

  locations = {
    alt     = var.locations.alt
    primary = var.locations.primary
  }

  networks = {
    primary_dmz = {
      location_name          = "primary"
      name                   = "${var.deployment_prefix}-${local.primary_location}-dmz-net01"
      address_space          = var.networks.primary.dmz.address_space
      dns_ip_addresses       = var.networks.primary.dmz.dns_ip_addresses
      enable_ddos_protection = var.networks.primary.dmz.enable_ddos_protection

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
      location_name          = "primary"
      name                   = "${var.deployment_prefix}-${local.primary_location}-shared-infra-net01"
      address_space          = var.networks.primary.shared_infra.address_space
      dns_ip_addresses       = var.networks.primary.shared_infra.dns_ip_addresses
      enable_ddos_protection = var.networks.primary.shared_infra.enable_ddos_protection

      subnets = {
        gateway = {
          name          = "GatewaySubnet"
          address_space = var.networks.primary.shared_infra.subnets.gateway.address_space
        }
        management = {
          address_space = var.networks.primary.shared_infra.subnets.management.address_space

          route_traffic = {
            to_main_through_appliance = {
              destined_for = {
                network = {
                  network_name = "primary_main"
                }
              }
              to_appliance = {
                ip_address = "10.0.1.254"
              }
            }
            to_main_odb_subnet_to_nowhere = {
              destined_for = {
                subnet = {
                  network_name = "primary_main"
                  subnet_name  = "odb"
                }
              }
              to_nowhere = true
            }
            to_main_cogito_subnet_to_gateway = {
              destined_for = {
                subnet = {
                  network_name = "primary_main"
                  subnet_name  = "cogito"
                }
              }
              to_gateway = true
            }
          }

          security_rules = {
            allow_in_from_hyperspace_web = {
              priority = 100
              protocol = "Tcp"
              allow = { in = { from = {
                network = {
                  network_name = "primary_hyperspace_web"
                } }
                to = {
                  port_range = 443
                } }
              }
            }
            allow_out_from_management = {
              priority = 110
              allow = { out = { from = {
                subnet = {
                  network_name = "primary_shared_infra"
                  subnet_name  = "management"
                } } }
              }
            }
            deny_in_to_management = {
              priority = 120
              deny = { in = { to = {
                subnet = {
                  network_name = "primary_shared_infra"
                  subnet_name  = "management"
                } } }
              }
            }
            deny_out_from_gateway = {
              priority = 130
              deny = { out = { from = {
                subnet = {
                  network_name = "primary_shared_infra"
                  subnet_name  = "gateway"
                } } }
              }
            }
          }
        }
      }

      peered_to = [
        "primary_hyperspace",
        "primary_hyperspace_web",
        "primary_main"
      ]
    }

    primary_main = {
      location_name          = "primary"
      name                   = "${var.deployment_prefix}-${local.primary_location}-main-net01"
      address_space          = var.networks.primary.main.address_space
      dns_ip_addresses       = var.networks.primary.main.dns_ip_addresses
      enable_ddos_protection = var.networks.primary.main.enable_ddos_protection

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
      location_name          = "primary"
      name                   = "${var.deployment_prefix}-${local.primary_location}-hyperspace-net01"
      address_space          = var.networks.primary.hyperspace.address_space
      dns_ip_addresses       = var.networks.primary.hyperspace.dns_ip_addresses
      enable_ddos_protection = var.networks.primary.hyperspace.enable_ddos_protection

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
      location_name          = "primary"
      name                   = "${var.deployment_prefix}-${local.primary_location}-hyperspace-web-net01"
      address_space          = var.networks.primary.hyperspace_web.address_space
      dns_ip_addresses       = var.networks.primary.hyperspace_web.dns_ip_addresses
      enable_ddos_protection = var.networks.primary.hyperspace_web.enable_ddos_protection

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
      location_name          = "alt"
      name                   = "${var.deployment_prefix}-${local.alt_location}-dmz-net01"
      address_space          = var.networks.alt.dmz.address_space
      dns_ip_addresses       = var.networks.alt.dmz.dns_ip_addresses
      enable_ddos_protection = var.networks.alt.dmz.enable_ddos_protection

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
      location_name          = "alt"
      name                   = "${var.deployment_prefix}-${local.alt_location}-shared-infra-net01"
      address_space          = var.networks.alt.shared_infra.address_space
      dns_ip_addresses       = var.networks.alt.shared_infra.dns_ip_addresses
      enable_ddos_protection = var.networks.alt.shared_infra.enable_ddos_protection

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
      location_name          = "alt"
      name                   = "${var.deployment_prefix}-${local.alt_location}-main-net01"
      address_space          = var.networks.alt.main.address_space
      dns_ip_addresses       = var.networks.alt.main.dns_ip_addresses
      enable_ddos_protection = var.networks.alt.main.enable_ddos_protection

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
      location_name          = "alt"
      name                   = "${var.deployment_prefix}-${local.alt_location}-hyperspace-net01"
      address_space          = var.networks.alt.hyperspace.address_space
      dns_ip_addresses       = var.networks.alt.hyperspace.dns_ip_addresses
      enable_ddos_protection = var.networks.alt.hyperspace.enable_ddos_protection

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
      location_name          = "alt"
      name                   = "${var.deployment_prefix}-${local.alt_location}-hyperspace-web-net01"
      address_space          = var.networks.alt.hyperspace_web.address_space
      dns_ip_addresses       = var.networks.alt.hyperspace_web.dns_ip_addresses
      enable_ddos_protection = var.networks.alt.hyperspace_web.enable_ddos_protection

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
          network_name                  = "primary_shared_infra"
          subnet_name                   = "management"
          enable_accelerated_networking = false
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

    primary_caboodle_db = try(var.workloads.primary.cogito.caboodle_db, null) == null ? null : {
      name                          = "${local.primary_location_prefix}cbd"
      resource_group_name           = "${local.primary_location}-caboodle-db"
      image                         = var.workloads.primary.cogito.caboodle_db.image
      capacity_reservation_group_id = var.workloads.primary.cogito.caboodle_db.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.cogito.caboodle_db.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "caboodle-db"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "odb"
        }
      }
    }

    primary_clarity_db = try(var.workloads.primary.cogito.clarity_db, null) == null ? null : {
      name                          = "${local.primary_location_prefix}cld"
      resource_group_name           = "${local.primary_location}-clarity-db"
      image                         = var.workloads.primary.cogito.clarity_db.image
      capacity_reservation_group_id = var.workloads.primary.cogito.clarity_db.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.cogito.clarity_db.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "clarity-db"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "odb"
        }
      }
    }

    primary_cubes = try(var.workloads.primary.cogito.cubes, null) == null ? null : {
      name                          = "${local.primary_location_prefix}cub"
      resource_group_name           = "${local.primary_location}-cubes"
      image                         = var.workloads.primary.cogito.cubes.image
      capacity_reservation_group_id = var.workloads.primary.cogito.cubes.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.cogito.cubes.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "cubes"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "odb"
        }
      }
    }

    primary_slicer_dicer = try(var.workloads.primary.cogito.slicer_dicer, null) == null ? null : {
      name                          = "${local.primary_location_prefix}sld"
      resource_group_name           = "${local.primary_location}-slicer-dicer"
      image                         = var.workloads.primary.cogito.slicer_dicer.image
      capacity_reservation_group_id = var.workloads.primary.cogito.slicer_dicer.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.cogito.slicer_dicer.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "slicerdicer"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "wss"
        }
      }
    }

    primary_clarity_console = try(var.workloads.primary.cogito.clarity_console, null) == null ? null : {
      name                          = "${local.primary_location_prefix}clc"
      resource_group_name           = "${local.primary_location}-clarity-console"
      image                         = var.workloads.primary.cogito.clarity_console.image
      capacity_reservation_group_id = var.workloads.primary.cogito.clarity_console.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.cogito.clarity_console.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "clarity-console"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "wss"
        }
      }
    }

    primary_bi_restful = try(var.workloads.primary.cogito.bi_restful, null) == null ? null : {
      name                          = "${local.primary_location_prefix}bir"
      resource_group_name           = "${local.primary_location}-bi-restful"
      image                         = var.workloads.primary.cogito.bi_restful.image
      capacity_reservation_group_id = var.workloads.primary.cogito.bi_restful.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.cogito.bi_restful.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "birestful"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "wss"
        }
      }
    }

    primary_odb = try(var.workloads.primary.odb.odb, null) == null ? null : {
      name                          = "${local.primary_location_prefix}odb"
      resource_group_name           = "${local.primary_location}-odb"
      image                         = var.workloads.primary.odb.odb.image
      capacity_reservation_group_id = var.workloads.primary.odb.odb.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.odb.odb.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "odb"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "odb"
        }
      }
    }

    primary_rpt = try(var.workloads.primary.odb.rpt, null) == null ? null : {
      name                          = "${local.primary_location_prefix}rpt"
      resource_group_name           = "${local.primary_location}-rpt"
      image                         = var.workloads.primary.odb.rpt.image
      capacity_reservation_group_id = var.workloads.primary.odb.rpt.capacity_reservation_group_id
      data_disks                    = var.workloads.primary.odb.rpt.data_disks
      location_name                 = "primary"
      os_type                       = "Windows"

      tags = {
        epic-app = "rpt"
      }

      network_interfaces = {
        default = {
          network_name = "primary_main"
          subnet_name  = "odb"
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
          network_name                  = "alt_shared_infra"
          subnet_name                   = "management"
          enable_accelerated_networking = false
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

    alt_caboodle_db = try(var.workloads.alt.cogito.caboodle_db, null) == null ? null : {
      name                          = "${local.alt_location_prefix}cbd"
      resource_group_name           = "${local.alt_location}-caboodle-db"
      image                         = var.workloads.alt.cogito.caboodle_db.image
      capacity_reservation_group_id = var.workloads.alt.cogito.caboodle_db.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.cogito.caboodle_db.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "caboodle-db"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "odb"
        }
      }
    }

    alt_clarity_db = try(var.workloads.alt.cogito.clarity_db, null) == null ? null : {
      name                          = "${local.alt_location_prefix}cld"
      resource_group_name           = "${local.alt_location}-clarity-db"
      image                         = var.workloads.alt.cogito.clarity_db.image
      capacity_reservation_group_id = var.workloads.alt.cogito.clarity_db.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.cogito.clarity_db.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "clarity-db"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "odb"
        }
      }
    }

    alt_cubes = try(var.workloads.alt.cogito.cubes, null) == null ? null : {
      name                          = "${local.alt_location_prefix}cub"
      resource_group_name           = "${local.alt_location}-cubes"
      image                         = var.workloads.alt.cogito.cubes.image
      capacity_reservation_group_id = var.workloads.alt.cogito.cubes.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.cogito.cubes.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "cubes"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "odb"
        }
      }
    }

    alt_slicer_dicer = try(var.workloads.alt.cogito.slicer_dicer, null) == null ? null : {
      name                          = "${local.alt_location_prefix}sld"
      resource_group_name           = "${local.alt_location}-slicer-dicer"
      image                         = var.workloads.alt.cogito.slicer_dicer.image
      capacity_reservation_group_id = var.workloads.alt.cogito.slicer_dicer.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.cogito.slicer_dicer.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "slicerdicer"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "wss"
        }
      }
    }

    alt_clarity_console = try(var.workloads.alt.cogito.clarity_console, null) == null ? null : {
      name                          = "${local.alt_location_prefix}clc"
      resource_group_name           = "${local.alt_location}-clarity-console"
      image                         = var.workloads.alt.cogito.clarity_console.image
      capacity_reservation_group_id = var.workloads.alt.cogito.clarity_console.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.cogito.clarity_console.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "clarity-console"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "wss"
        }
      }
    }

    alt_bi_restful = try(var.workloads.alt.cogito.bi_restful, null) == null ? null : {
      name                          = "${local.alt_location_prefix}bir"
      resource_group_name           = "${local.alt_location}-bi-restful"
      image                         = var.workloads.alt.cogito.bi_restful.image
      capacity_reservation_group_id = var.workloads.alt.cogito.bi_restful.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.cogito.bi_restful.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "birestful"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "wss"
        }
      }
    }

    alt_odb = try(var.workloads.alt.odb.odb, null) == null ? null : {
      name                          = "${local.alt_location_prefix}odb"
      resource_group_name           = "${local.alt_location}-odb"
      image                         = var.workloads.alt.odb.odb.image
      capacity_reservation_group_id = var.workloads.alt.odb.odb.capacity_reservation_group_id
      data_disks                    = var.workloads.alt.odb.odb.data_disks
      location_name                 = "alt"
      os_type                       = "Windows"

      tags = {
        epic-app = "odb"
      }

      network_interfaces = {
        default = {
          network_name = "alt_main"
          subnet_name  = "odb"
        }
      }
    }
  }

  virtual_machine_set_zone_distribution = {
    primary_arr                 = try(var.workload_zone_distribution.primary.client.arr, { custom = null, even = ["1", "2", "3"] })
    primary_bca_pc              = try(var.workload_zone_distribution.primary.client.bca_pc, { custom = null, even = ["1", "2", "3"] })
    primary_bca_web             = try(var.workload_zone_distribution.primary.client.bca_web, { custom = null, even = ["1", "2", "3"] })
    primary_care_everywhere     = try(var.workload_zone_distribution.primary.client.care_everywhere, { custom = null, even = ["1", "2", "3"] })
    primary_care_everywhere_arr = try(var.workload_zone_distribution.primary.client.care_everywhere_arr, { custom = null, even = ["1", "2", "3"] })
    primary_digital_signing     = try(var.workload_zone_distribution.primary.client.digital_signing, { custom = null, even = ["1", "2", "3"] })
    primary_epiccare_link       = try(var.workload_zone_distribution.primary.client.epiccare_link, { custom = null, even = ["1", "2", "3"] })
    primary_hyperspace_web      = try(var.workload_zone_distribution.primary.client.hyperspace_web, { custom = null, even = ["1", "2", "3"] })
    primary_interconnect        = try(var.workload_zone_distribution.primary.client.interconnect, { custom = null, even = ["1", "2", "3"] })
    primary_mpsql               = try(var.workload_zone_distribution.primary.client.mpsql, { custom = null, even = ["1", "2", "3"] })
    primary_system_pulse        = try(var.workload_zone_distribution.primary.client.system_pulse, { custom = null, even = ["1", "2", "3"] })
    primary_web_blob            = try(var.workload_zone_distribution.primary.client.web_blob, { custom = null, even = ["1", "2", "3"] })
    primary_eps                 = try(var.workload_zone_distribution.primary.client.eps, { custom = null, even = ["1", "2", "3"] })
    primary_kuiper              = try(var.workload_zone_distribution.primary.client.kuiper, { custom = null, even = ["1", "2", "3"] })
    primary_mychart             = try(var.workload_zone_distribution.primary.client.mychart, { custom = null, even = ["1", "2", "3"] })
    primary_sts                 = try(var.workload_zone_distribution.primary.client.sts, { custom = null, even = ["1", "2", "3"] })
    primary_citrix_cc           = try(var.workload_zone_distribution.primary.client.citrix_cc, { custom = null, even = ["1", "2", "3"] })
    primary_willow              = try(var.workload_zone_distribution.primary.client.willow, { custom = null, even = ["1", "2", "3"] })
    primary_image_exchange      = try(var.workload_zone_distribution.primary.client.image_exchange, { custom = null, even = ["1", "2", "3"] })
    primary_clarity_db          = try(var.workload_zone_distribution.primary.cogito.clarity_db, { custom = null, even = ["1", "2", "3"] })
    primary_caboodle_db         = try(var.workload_zone_distribution.primary.cogito.caboodle_db, { custom = null, even = ["1", "2", "3"] })
    primary_cubes               = try(var.workload_zone_distribution.primary.cogito.cubes, { custom = null, even = ["1", "2", "3"] })
    primary_slicer_dicer        = try(var.workload_zone_distribution.primary.cogito.slicer_dicer, { custom = null, even = ["1", "2", "3"] })
    primary_clarity_console     = try(var.workload_zone_distribution.primary.cogito.clarity_console, { custom = null, even = ["1", "2", "3"] })
    primary_bi_restful          = try(var.workload_zone_distribution.primary.cogito.bi_restful, { custom = null, even = ["1", "2", "3"] })
    primary_odb                 = try(var.workload_zone_distribution.primary.odb.odb, { custom = null, even = ["1", "2", "3"] })
    primary_rpt                 = try(var.workload_zone_distribution.primary.odb.rpt, { custom = null, even = ["1", "2", "3"] })

    alt_arr                 = try(var.workload_zone_distribution.alt.client.arr, { custom = null, even = ["1", "2", "3"] })
    alt_bca_pc              = try(var.workload_zone_distribution.alt.client.bca_pc, { custom = null, even = ["1", "2", "3"] })
    alt_bca_web             = try(var.workload_zone_distribution.alt.client.bca_web, { custom = null, even = ["1", "2", "3"] })
    alt_care_everywhere     = try(var.workload_zone_distribution.alt.client.care_everywhere, { custom = null, even = ["1", "2", "3"] })
    alt_care_everywhere_arr = try(var.workload_zone_distribution.alt.client.care_everywhere_arr, { custom = null, even = ["1", "2", "3"] })
    alt_digital_signing     = try(var.workload_zone_distribution.alt.client.digital_signing, { custom = null, even = ["1", "2", "3"] })
    alt_epiccare_link       = try(var.workload_zone_distribution.alt.client.epiccare_link, { custom = null, even = ["1", "2", "3"] })
    alt_hyperspace_web      = try(var.workload_zone_distribution.alt.client.hyperspace_web, { custom = null, even = ["1", "2", "3"] })
    alt_interconnect        = try(var.workload_zone_distribution.alt.client.interconnect, { custom = null, even = ["1", "2", "3"] })
    alt_mpsql               = try(var.workload_zone_distribution.alt.client.mpsql, { custom = null, even = ["1", "2", "3"] })
    alt_system_pulse        = try(var.workload_zone_distribution.alt.client.system_pulse, { custom = null, even = ["1", "2", "3"] })
    alt_web_blob            = try(var.workload_zone_distribution.alt.client.web_blob, { custom = null, even = ["1", "2", "3"] })
    alt_eps                 = try(var.workload_zone_distribution.alt.client.eps, { custom = null, even = ["1", "2", "3"] })
    alt_kuiper              = try(var.workload_zone_distribution.alt.client.kuiper, { custom = null, even = ["1", "2", "3"] })
    alt_mychart             = try(var.workload_zone_distribution.alt.client.mychart, { custom = null, even = ["1", "2", "3"] })
    alt_sts                 = try(var.workload_zone_distribution.alt.client.sts, { custom = null, even = ["1", "2", "3"] })
    alt_citrix_cc           = try(var.workload_zone_distribution.alt.client.citrix_cc, { custom = null, even = ["1", "2", "3"] })
    alt_willow              = try(var.workload_zone_distribution.alt.client.willow, { custom = null, even = ["1", "2", "3"] })
    alt_image_exchange      = try(var.workload_zone_distribution.alt.client.image_exchange, { custom = null, even = ["1", "2", "3"] })
    alt_clarity_db          = try(var.workload_zone_distribution.alt.cogito.clarity_db, { custom = null, even = ["1", "2", "3"] })
    alt_caboodle_db         = try(var.workload_zone_distribution.alt.cogito.caboodle_db, { custom = null, even = ["1", "2", "3"] })
    alt_cubes               = try(var.workload_zone_distribution.alt.cogito.cubes, { custom = null, even = ["1", "2", "3"] })
    alt_slicer_dicer        = try(var.workload_zone_distribution.alt.cogito.slicer_dicer, { custom = null, even = ["1", "2", "3"] })
    alt_clarity_console     = try(var.workload_zone_distribution.alt.cogito.clarity_console, { custom = null, even = ["1", "2", "3"] })
    alt_bi_restful          = try(var.workload_zone_distribution.alt.cogito.bi_restful, { custom = null, even = ["1", "2", "3"] })
    alt_odb                 = try(var.workload_zone_distribution.alt.odb.odb, { custom = null, even = ["1", "2", "3"] })
  }

  virtual_machine_set_specs = {
    primary_arr                 = try(var.workload_specs.primary.client.arr, null)
    primary_bca_pc              = try(var.workload_specs.primary.client.bca_pc, null)
    primary_bca_web             = try(var.workload_specs.primary.client.bca_web, null)
    primary_care_everywhere     = try(var.workload_specs.primary.client.care_everywhere, null)
    primary_care_everywhere_arr = try(var.workload_specs.primary.client.care_everywhere_arr, null)
    primary_digital_signing     = try(var.workload_specs.primary.client.digital_signing, null)
    primary_epiccare_link       = try(var.workload_specs.primary.client.epiccare_link, null)
    primary_hyperspace_web      = try(var.workload_specs.primary.client.hyperspace_web, null)
    primary_interconnect        = try(var.workload_specs.primary.client.interconnect, null)
    primary_mpsql               = try(var.workload_specs.primary.client.mpsql, null)
    primary_system_pulse        = try(var.workload_specs.primary.client.system_pulse, null)
    primary_web_blob            = try(var.workload_specs.primary.client.web_blob, null)
    primary_eps                 = try(var.workload_specs.primary.client.eps, null)
    primary_kuiper              = try(var.workload_specs.primary.client.kuiper, null)
    primary_mychart             = try(var.workload_specs.primary.client.mychart, null)
    primary_sts                 = try(var.workload_specs.primary.client.sts, null)
    primary_citrix_cc           = try(var.workload_specs.primary.client.citrix_cc, null)
    primary_willow              = try(var.workload_specs.primary.client.willow, null)
    primary_image_exchange      = try(var.workload_specs.primary.client.image_exchange, null)
    primary_clarity_db          = try(var.workload_specs.primary.cogito.clarity_db, null)
    primary_caboodle_db         = try(var.workload_specs.primary.cogito.caboodle_db, null)
    primary_cubes               = try(var.workload_specs.primary.cogito.cubes, null)
    primary_slicer_dicer        = try(var.workload_specs.primary.cogito.slicer_dicer, null)
    primary_clarity_console     = try(var.workload_specs.primary.cogito.clarity_console, null)
    primary_bi_restful          = try(var.workload_specs.primary.cogito.bi_restful, null)
    primary_odb                 = try(var.workload_specs.primary.odb.odb, null)
    primary_rpt                 = try(var.workload_specs.primary.odb.rpt, null)

    alt_arr                 = try(var.workload_specs.alt.client.arr, null)
    alt_bca_pc              = try(var.workload_specs.alt.client.bca_pc, null)
    alt_bca_web             = try(var.workload_specs.alt.client.bca_web, null)
    alt_care_everywhere     = try(var.workload_specs.alt.client.care_everywhere, null)
    alt_care_everywhere_arr = try(var.workload_specs.alt.client.care_everywhere_arr, null)
    alt_digital_signing     = try(var.workload_specs.alt.client.digital_signing, null)
    alt_epiccare_link       = try(var.workload_specs.alt.client.epiccare_link, null)
    alt_hyperspace_web      = try(var.workload_specs.alt.client.hyperspace_web, null)
    alt_interconnect        = try(var.workload_specs.alt.client.interconnect, null)
    alt_mpsql               = try(var.workload_specs.alt.client.mpsql, null)
    alt_system_pulse        = try(var.workload_specs.alt.client.system_pulse, null)
    alt_web_blob            = try(var.workload_specs.alt.client.web_blob, null)
    alt_eps                 = try(var.workload_specs.alt.client.eps, null)
    alt_kuiper              = try(var.workload_specs.alt.client.kuiper, null)
    alt_mychart             = try(var.workload_specs.alt.client.mychart, null)
    alt_sts                 = try(var.workload_specs.alt.client.sts, null)
    alt_citrix_cc           = try(var.workload_specs.alt.client.citrix_cc, null)
    alt_willow              = try(var.workload_specs.alt.client.willow, null)
    alt_image_exchange      = try(var.workload_specs.alt.client.image_exchange, null)
    alt_clarity_db          = try(var.workload_specs.alt.cogito.clarity_db, null)
    alt_caboodle_db         = try(var.workload_specs.alt.cogito.caboodle_db, null)
    alt_cubes               = try(var.workload_specs.alt.cogito.cubes, null)
    alt_slicer_dicer        = try(var.workload_specs.alt.cogito.slicer_dicer, null)
    alt_clarity_console     = try(var.workload_specs.alt.cogito.clarity_console, null)
    alt_bi_restful          = try(var.workload_specs.alt.cogito.bi_restful, null)
    alt_odb                 = try(var.workload_specs.alt.odb.odb, null)
  }
}
