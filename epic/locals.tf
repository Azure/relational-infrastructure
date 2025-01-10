locals {
  deploy_alt     = tobool(var.alt_location != null)
  deploy_primary = tobool(var.primary_location != null)
}

locals {
  alt_resource_prefix     = "${var.deployment_prefix}${var.prefix_region_alt}"
  primary_resource_prefix = "${var.deployment_prefix}${var.prefix_region_primary}"
}

locals {
  alt_networks_rg_name        = "${local.alt_resource_prefix}-network"
  alt_arr_rg_name             = "${local.alt_resource_prefix}-arr"
  alt_bca_rg_name             = "${local.alt_resource_prefix}-bca"
  alt_care_everywhere_rg_name = "${local.alt_resource_prefix}-care-everywhere"
  alt_dss_rg_name             = "${local.alt_resource_prefix}-dss"
  alt_epiccare_link_rg_name   = "${local.alt_resource_prefix}-epiccare-link"
  alt_hyperspace_web_rg_name  = "${local.alt_resource_prefix}-hyperspace-web"
  alt_hyperspace_rg_name      = "${local.alt_resource_prefix}-hyperspace"
  alt_hyperdrive_rg_name      = "${local.alt_resource_prefix}-hyperdrive"
  alt_interconnect_rg_name    = "${local.alt_resource_prefix}-interconnect"
  alt_system_pulse_rg_name    = "${local.alt_resource_prefix}-system-pulse"
  alt_wbs_rg_name             = "${local.alt_resource_prefix}-wbs"
  alt_eps_rg_name             = "${local.alt_resource_prefix}-eps"
  alt_kuiper_rg_name          = "${local.alt_resource_prefix}-kuiper"
  alt_mychart_rg_name         = "${local.alt_resource_prefix}-mychart"
  alt_sts_rg_name             = "${local.alt_resource_prefix}-sts"
  alt_welcome_web_rg_name     = "${local.alt_resource_prefix}-welcome-web"
  alt_citrix_rg_name          = "${local.alt_resource_prefix}-citrix"
  alt_willow_rg_name          = "${local.alt_resource_prefix}-willow"
  alt_image_exchange_rg_name  = "${local.alt_resource_prefix}-image-exchange"
  alt_odb_rg_name             = "${local.alt_resource_prefix}-odb"
  alt_cogito_rg_name          = "${local.alt_resource_prefix}-cogito"
  alt_mpsql_rg_name           = "${local.alt_resource_prefix}-mpsql"

  primary_networks_rg_name        = "${local.primary_resource_prefix}-network"
  primary_arr_rg_name             = "${local.primary_resource_prefix}-arr"
  primary_bca_rg_name             = "${local.primary_resource_prefix}-bca"
  primary_care_everywhere_rg_name = "${local.primary_resource_prefix}-care-everywhere"
  primary_dss_rg_name             = "${local.primary_resource_prefix}-dss"
  primary_epiccare_link_rg_name   = "${local.primary_resource_prefix}-epiccare-link"
  primary_hyperspace_web_rg_name  = "${local.primary_resource_prefix}-hyperspace-web"
  primary_hyperspace_rg_name      = "${local.primary_resource_prefix}-hyperspace"
  primary_hyperdrive_rg_name      = "${local.primary_resource_prefix}-hyperdrive"
  primary_interconnect_rg_name    = "${local.primary_resource_prefix}-interconnect"
  primary_system_pulse_rg_name    = "${local.primary_resource_prefix}-system-pulse"
  primary_wbs_rg_name             = "${local.primary_resource_prefix}-wbs"
  primary_eps_rg_name             = "${local.primary_resource_prefix}-eps"
  primary_kuiper_rg_name          = "${local.primary_resource_prefix}-kuiper"
  primary_mychart_rg_name         = "${local.primary_resource_prefix}-mychart"
  primary_sts_rg_name             = "${local.primary_resource_prefix}-sts"
  primary_welcome_web_rg_name     = "${local.primary_resource_prefix}-welcome-web"
  primary_citrix_rg_name          = "${local.primary_resource_prefix}-citrix"
  primary_willow_rg_name          = "${local.primary_resource_prefix}-willow"
  primary_image_exchange_rg_name  = "${local.primary_resource_prefix}-image-exchange"
  primary_odb_rg_name             = "${local.primary_resource_prefix}-odb"
  primary_cogito_rg_name          = "${local.primary_resource_prefix}-cogito"
  primary_mpsql_rg_name           = "${local.primary_resource_prefix}-mpsql"
}

locals {
  alt_dmz_vnet_name                = "${local.alt_resource_prefix}${var.prefix_network_dmz}"
  alt_shared_infra_vnet_name       = "${local.alt_resource_prefix}${var.prefix_network_shared_infra}"
  alt_main_vnet_name               = "${local.alt_resource_prefix}${var.prefix_network_main}"
  alt_hyperspace_vnet_name         = "${local.alt_resource_prefix}${var.prefix_network_hyperspace}"
  alt_hyperspace_web_vnet_name     = "${local.alt_resource_prefix}${var.prefix_network_hyperspace_web}"
  primary_dmz_vnet_name            = "${local.primary_resource_prefix}${var.prefix_network_dmz}"
  primary_shared_infra_vnet_name   = "${local.primary_resource_prefix}${var.prefix_network_shared_infra}"
  primary_main_vnet_name           = "${local.primary_resource_prefix}${var.prefix_network_main}"
  primary_hyperspace_vnet_name     = "${local.primary_resource_prefix}${var.prefix_network_hyperspace}"
  primary_hyperspace_web_vnet_name = "${local.primary_resource_prefix}${var.prefix_network_hyperspace_web}"
}

locals {
  alt_arr_prefix                 = "${local.alt_resource_prefix}${var.prefix_arr}"
  alt_bca_pc_prefix              = "${local.alt_resource_prefix}${var.prefix_bca_pc}"
  alt_bca_web_prefix             = "${local.alt_resource_prefix}${var.prefix_bca_web}"
  alt_care_everywhere_prefix     = "${local.alt_resource_prefix}${var.prefix_care_everywhere}"
  alt_care_everywhere_arr_prefix = "${local.alt_resource_prefix}${var.prefix_care_everywhere_arr}"
  alt_dss_prefix                 = "${local.alt_resource_prefix}${var.prefix_dss}"
  alt_epiccare_link_prefix       = "${local.alt_resource_prefix}${var.prefix_epiccare_link}"
  alt_hyperspace_web_prefix      = "${local.alt_resource_prefix}${var.prefix_hyperspace_web}"
  alt_hyperspace_prefix          = "${local.alt_resource_prefix}${var.prefix_hyperspace}"
  alt_hyperdrive_prefix          = "${local.alt_resource_prefix}${var.prefix_hyperdrive}"
  alt_interconnect_prefix        = "${local.alt_resource_prefix}${var.prefix_interconnect}"
  alt_system_pulse_prefix        = "${local.alt_resource_prefix}${var.prefix_system_pulse}"
  alt_wbs_prefix                 = "${local.alt_resource_prefix}${var.prefix_wbs}"
  alt_eps_prefix                 = "${local.alt_resource_prefix}${var.prefix_eps}"
  alt_kuiper_prefix              = "${local.alt_resource_prefix}${var.prefix_kuiper}"
  alt_mychart_prefix             = "${local.alt_resource_prefix}${var.prefix_mychart}"
  alt_sts_prefix                 = "${local.alt_resource_prefix}${var.prefix_sts}"
  alt_welcome_web_prefix         = "${local.alt_resource_prefix}${var.prefix_welcome_web}"
  alt_citrix_cc_prefix           = "${local.alt_resource_prefix}${var.prefix_citrix_cc}"
  alt_citrix_vda_prefix          = "${local.alt_resource_prefix}${var.prefix_citrix_vda}"
  alt_willow_prefix              = "${local.alt_resource_prefix}${var.prefix_willow}"
  alt_image_exchange_prefix      = "${local.alt_resource_prefix}${var.prefix_image_exchange}"
  alt_odb_prefix                 = "${local.alt_resource_prefix}${var.prefix_odb}"
  alt_odb_ecp_app_prefix         = "${local.alt_resource_prefix}${var.prefix_odb_ecp_app}"
  alt_odb_ecp_util_prefix        = "${local.alt_resource_prefix}${var.prefix_odb_ecp_util}"
  alt_rpt_prefix                 = "${local.alt_resource_prefix}${var.prefix_rpt}"
  alt_rpt_ecp_util_prefix        = "${local.alt_resource_prefix}${var.prefix_rpt_ecp_util}"
  alt_caboodle_db_prefix         = "${local.alt_resource_prefix}${var.prefix_caboodle_db}"
  alt_clarity_db_prefix          = "${local.alt_resource_prefix}${var.prefix_clarity_db}"
  alt_caboodle_console_prefix    = "${local.alt_resource_prefix}${var.prefix_caboodle_console}"
  alt_clarity_console_prefix     = "${local.alt_resource_prefix}${var.prefix_clarity_console}"
  alt_caboodle_etl_prefix        = "${local.alt_resource_prefix}${var.prefix_caboodle_etl}"
  alt_slicerdicer_prefix         = "${local.alt_resource_prefix}${var.prefix_slicerdicer}"
  alt_birestful_prefix           = "${local.alt_resource_prefix}${var.prefix_birestful}"
  alt_mpsql_prefix               = "${local.alt_resource_prefix}${var.prefix_mpsql}"
  alt_cubes_prefix               = "${local.alt_resource_prefix}${var.prefix_cubes}"

  primary_arr_prefix                 = "${local.primary_resource_prefix}${var.prefix_arr}"
  primary_bca_pc_prefix              = "${local.primary_resource_prefix}${var.prefix_bca_pc}"
  primary_bca_web_prefix             = "${local.primary_resource_prefix}${var.prefix_bca_web}"
  primary_care_everywhere_prefix     = "${local.primary_resource_prefix}${var.prefix_care_everywhere}"
  primary_care_everywhere_arr_prefix = "${local.primary_resource_prefix}${var.prefix_care_everywhere_arr}"
  primary_dss_prefix                 = "${local.primary_resource_prefix}${var.prefix_dss}"
  primary_epiccare_link_prefix       = "${local.primary_resource_prefix}${var.prefix_epiccare_link}"
  primary_hyperspace_web_prefix      = "${local.primary_resource_prefix}${var.prefix_hyperspace_web}"
  primary_hyperspace_prefix          = "${local.primary_resource_prefix}${var.prefix_hyperspace}"
  primary_hyperdrive_prefix          = "${local.primary_resource_prefix}${var.prefix_hyperdrive}"
  primary_interconnect_prefix        = "${local.primary_resource_prefix}${var.prefix_interconnect}"
  primary_system_pulse_prefix        = "${local.primary_resource_prefix}${var.prefix_system_pulse}"
  primary_wbs_prefix                 = "${local.primary_resource_prefix}${var.prefix_wbs}"
  primary_eps_prefix                 = "${local.primary_resource_prefix}${var.prefix_eps}"
  primary_kuiper_prefix              = "${local.primary_resource_prefix}${var.prefix_kuiper}"
  primary_mychart_prefix             = "${local.primary_resource_prefix}${var.prefix_mychart}"
  primary_sts_prefix                 = "${local.primary_resource_prefix}${var.prefix_sts}"
  primary_welcome_web_prefix         = "${local.primary_resource_prefix}${var.prefix_welcome_web}"
  primary_citrix_cc_prefix           = "${local.primary_resource_prefix}${var.prefix_citrix_cc}"
  primary_citrix_vda_prefix          = "${local.primary_resource_prefix}${var.prefix_citrix_vda}"
  primary_willow_prefix              = "${local.primary_resource_prefix}${var.prefix_willow}"
  primary_image_exchange_prefix      = "${local.primary_resource_prefix}${var.prefix_image_exchange}"
  primary_odb_prefix                 = "${local.primary_resource_prefix}${var.prefix_odb}"
  primary_odb_ecp_app_prefix         = "${local.primary_resource_prefix}${var.prefix_odb_ecp_app}"
  primary_odb_ecp_util_prefix        = "${local.primary_resource_prefix}${var.prefix_odb_ecp_util}"
  primary_rpt_prefix                 = "${local.primary_resource_prefix}${var.prefix_rpt}"
  primary_rpt_ecp_util_prefix        = "${local.primary_resource_prefix}${var.prefix_rpt_ecp_util}"
  primary_caboodle_db_prefix         = "${local.primary_resource_prefix}${var.prefix_caboodle_db}"
  primary_clarity_db_prefix          = "${local.primary_resource_prefix}${var.prefix_clarity_db}"
  primary_caboodle_console_prefix    = "${local.primary_resource_prefix}${var.prefix_caboodle_console}"
  primary_clarity_console_prefix     = "${local.primary_resource_prefix}${var.prefix_clarity_console}"
  primary_caboodle_etl_prefix        = "${local.primary_resource_prefix}${var.prefix_caboodle_etl}"
  primary_slicerdicer_prefix         = "${local.primary_resource_prefix}${var.prefix_slicerdicer}"
  primary_birestful_prefix           = "${local.primary_resource_prefix}${var.prefix_birestful}"
  primary_mpsql_prefix               = "${local.primary_resource_prefix}${var.prefix_mpsql}"
  primary_cubes_prefix               = "${local.primary_resource_prefix}${var.prefix_cubes}"
}

locals {
  alt_dmz_vnet_subnets = {
    firewall = {
      name           = "FirewallSubnet"
      address_prefix = var.alt_networks.dmz.subnets.firewall_space
    }
    production = {
      name           = "ProductionSubnet"
      address_prefix = var.alt_networks.dmz.subnets.production_space
    }
    non_production = {
      name           = "NonProductionSubnet"
      address_prefix = var.alt_networks.dmz.subnets.non_production_space
    }
  }

  alt_shared_infra_vnet_subnets = {
    gateway = {
      name           = "GatewaySubnet"
      address_prefix = var.alt_networks.shared_infra.subnets.gateway_space
    }
    management = {
      name           = "ManagementSubnet"
      address_prefix = var.alt_networks.shared_infra.subnets.management_space
    }
  }

  alt_main_vnet_subnets = {
    odb = {
      name           = "ODBSubnet"
      address_prefix = var.alt_networks.main.subnets.odb_space
    }
    wss = {
      name           = "WSSSubnet"
      address_prefix = var.alt_networks.main.subnets.wss_space
    }
    cogito = {
      name           = "CogitoSubnet"
      address_prefix = var.alt_networks.main.subnets.cogito_space
    }
  }

  alt_hyperspace_vnet_subnets = {
    hyperspace = {
      name           = "HyperspaceSubnet"
      address_prefix = var.alt_networks.hyperspace.subnets.hyperspace_space
    }
  }

  alt_hyperspace_web_vnet_subnets = {
    hyperspace_web = {
      name           = "HyperspaceWebSubnet"
      address_prefix = var.alt_networks.hyperspace_web.subnets.hyperspace_web_space
    }
  }

  primary_dmz_vnet_subnets = {
    firewall = {
      name           = "FirewallSubnet"
      address_prefix = var.primary_networks.dmz.subnets.firewall_space
    }
    production = {
      name           = "ProductionSubnet"
      address_prefix = var.primary_networks.dmz.subnets.production_space
    }
    non_production = {
      name           = "NonProductionSubnet"
      address_prefix = var.primary_networks.dmz.subnets.non_production_space
    }
  }

  primary_shared_infra_vnet_subnets = {
    gateway = {
      name           = "GatewaySubnet"
      address_prefix = var.primary_networks.shared_infra.subnets.gateway_space
    }
    management = {
      name           = "ManagementSubnet"
      address_prefix = var.primary_networks.shared_infra.subnets.management_space
    }
  }

  primary_main_vnet_subnets = {
    odb = {
      name           = "ODBSubnet"
      address_prefix = var.primary_networks.main.subnets.odb_space
    }
    wss = {
      name           = "WSSSubnet"
      address_prefix = var.primary_networks.main.subnets.wss_space
    }
    cogito = {
      name           = "CogitoSubnet"
      address_prefix = var.primary_networks.main.subnets.cogito_space
    }
  }

  primary_hyperspace_vnet_subnets = {
    hyperspace = {
      name           = "HyperspaceSubnet"
      address_prefix = var.primary_networks.hyperspace.subnets.hyperspace_space
    }
  }

  primary_hyperspace_web_vnet_subnets = {
    hyperspace_web = {
      name           = "HyperspaceWebSubnet"
      address_prefix = var.primary_networks.hyperspace_web.subnets.hyperspace_web_space
    }
  }
}
