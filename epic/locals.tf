locals {
  deploy_alt     = tobool(var.alt_location != null)
  deploy_primary = tobool(var.primary_location != null)
}

locals {
  alt_resource_prefix     = "${var.deployment_prefix}${var.location_prefixes.alt}"
  primary_resource_prefix = "${var.deployment_prefix}${var.location_prefixes.primary}"
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
  alt_dmz_vnet_name                = "${local.alt_resource_prefix}${var.network_prefixes.dmz}"
  alt_shared_infra_vnet_name       = "${local.alt_resource_prefix}${var.network_prefixes.shared_infra}"
  alt_main_vnet_name               = "${local.alt_resource_prefix}${var.network_prefixes.main}"
  alt_hyperspace_vnet_name         = "${local.alt_resource_prefix}${var.network_prefixes.hyperspace}"
  alt_hyperspace_web_vnet_name     = "${local.alt_resource_prefix}${var.network_prefixes.hyperspace_web}"
  primary_dmz_vnet_name            = "${local.primary_resource_prefix}${var.network_prefixes.dmz}"
  primary_shared_infra_vnet_name   = "${local.primary_resource_prefix}${var.network_prefixes.shared_infra}"
  primary_main_vnet_name           = "${local.primary_resource_prefix}${var.network_prefixes.main}"
  primary_hyperspace_vnet_name     = "${local.primary_resource_prefix}${var.network_prefixes.hyperspace}"
  primary_hyperspace_web_vnet_name = "${local.primary_resource_prefix}${var.network_prefixes.hyperspace_web}"
}

locals {
  alt_arr_prefix                 = "${local.alt_resource_prefix}${var.app_prefixes.client.arr}"
  alt_bca_pc_prefix              = "${local.alt_resource_prefix}${var.app_prefixes.client.bca_pc}"
  alt_bca_web_prefix             = "${local.alt_resource_prefix}${var.app_prefixes.client.bca_web}"
  alt_care_everywhere_prefix     = "${local.alt_resource_prefix}${var.app_prefixes.client.care_everywhere}"
  alt_care_everywhere_arr_prefix = "${local.alt_resource_prefix}${var.app_prefixes.client.care_everywhere_arr}"
  alt_digital_signing_prefix     = "${local.alt_resource_prefix}${var.app_prefixes.client.digital_signing}"
  alt_epiccare_link_prefix       = "${local.alt_resource_prefix}${var.app_prefixes.client.epiccare_link}"
  alt_hyperspace_web_prefix      = "${local.alt_resource_prefix}${var.app_prefixes.client.hyperspace_web}"
  alt_hyperspace_prefix          = "${local.alt_resource_prefix}${var.app_prefixes.client.hyperspace}"
  alt_hyperdrive_prefix          = "${local.alt_resource_prefix}${var.app_prefixes.client.hyperdrive}"
  alt_interconnect_prefix        = "${local.alt_resource_prefix}${var.app_prefixes.client.interconnect}"
  alt_system_pulse_prefix        = "${local.alt_resource_prefix}${var.app_prefixes.client.system_pulse}"
  alt_web_blob_prefix            = "${local.alt_resource_prefix}${var.app_prefixes.client.web_blob}"
  alt_eps_prefix                 = "${local.alt_resource_prefix}${var.app_prefixes.client.eps}"
  alt_kuiper_prefix              = "${local.alt_resource_prefix}${var.app_prefixes.client.kuiper}"
  alt_mpsql_prefix               = "${local.alt_resource_prefix}${var.app_prefixes.client.mpsql}"
  alt_mychart_prefix             = "${local.alt_resource_prefix}${var.app_prefixes.client.mychart}"
  alt_sts_prefix                 = "${local.alt_resource_prefix}${var.app_prefixes.client.sts}"
  alt_welcome_web_prefix         = "${local.alt_resource_prefix}${var.app_prefixes.client.welcome_web}"
  alt_citrix_cc_prefix           = "${local.alt_resource_prefix}${var.app_prefixes.client.citrix_cc}"
  alt_citrix_vda_prefix          = "${local.alt_resource_prefix}${var.app_prefixes.client.citrix_vda}"
  alt_willow_prefix              = "${local.alt_resource_prefix}${var.app_prefixes.client.willow}"
  alt_image_exchange_prefix      = "${local.alt_resource_prefix}${var.app_prefixes.client.image_exchange}"
  alt_odb_prefix                 = "${local.alt_resource_prefix}${var.app_prefixes.odb.odb}"
  alt_odb_ecp_app_prefix         = "${local.alt_resource_prefix}${var.app_prefixes.odb.odb_ecp_app}"
  alt_odb_ecp_util_prefix        = "${local.alt_resource_prefix}${var.app_prefixes.odb.odb_ecp_util}"
  alt_rpt_prefix                 = "${local.alt_resource_prefix}${var.app_prefixes.odb.rpt}"
  alt_rpt_ecp_util_prefix        = "${local.alt_resource_prefix}${var.app_prefixes.odb.rpt_ecp_util}"
  alt_caboodle_db_prefix         = "${local.alt_resource_prefix}${var.app_prefixes.cogito.caboodle_db}"
  alt_clarity_db_prefix          = "${local.alt_resource_prefix}${var.app_prefixes.cogito.clarity_db}"
  alt_caboodle_console_prefix    = "${local.alt_resource_prefix}${var.app_prefixes.cogito.caboodle_console}"
  alt_clarity_console_prefix     = "${local.alt_resource_prefix}${var.app_prefixes.cogito.clarity_console}"
  alt_caboodle_etl_prefix        = "${local.alt_resource_prefix}${var.app_prefixes.cogito.caboodle_etl}"
  alt_slicerdicer_prefix         = "${local.alt_resource_prefix}${var.app_prefixes.cogito.slicerdicer}"
  alt_birestful_prefix           = "${local.alt_resource_prefix}${var.app_prefixes.cogito.bi_restful}"
  alt_cubes_prefix               = "${local.alt_resource_prefix}${var.app_prefixes.cogito.cubes}"

  primary_arr_prefix                 = "${local.primary_resource_prefix}${var.app_prefixes.client.arr}"
  primary_bca_pc_prefix              = "${local.primary_resource_prefix}${var.app_prefixes.client.bca_pc}"
  primary_bca_web_prefix             = "${local.primary_resource_prefix}${var.app_prefixes.client.bca_web}"
  primary_care_everywhere_prefix     = "${local.primary_resource_prefix}${var.app_prefixes.client.care_everywhere}"
  primary_care_everywhere_arr_prefix = "${local.primary_resource_prefix}${var.app_prefixes.client.care_everywhere_arr}"
  primary_digital_signing_prefix     = "${local.primary_resource_prefix}${var.app_prefixes.client.digital_signing}"
  primary_epiccare_link_prefix       = "${local.primary_resource_prefix}${var.app_prefixes.client.epiccare_link}"
  primary_hyperspace_web_prefix      = "${local.primary_resource_prefix}${var.app_prefixes.client.hyperspace_web}"
  primary_hyperspace_prefix          = "${local.primary_resource_prefix}${var.app_prefixes.client.hyperspace}"
  primary_hyperdrive_prefix          = "${local.primary_resource_prefix}${var.app_prefixes.client.hyperdrive}"
  primary_interconnect_prefix        = "${local.primary_resource_prefix}${var.app_prefixes.client.interconnect}"
  primary_system_pulse_prefix        = "${local.primary_resource_prefix}${var.app_prefixes.client.system_pulse}"
  primary_web_blob_prefix            = "${local.primary_resource_prefix}${var.app_prefixes.client.web_blob}"
  primary_eps_prefix                 = "${local.primary_resource_prefix}${var.app_prefixes.client.eps}"
  primary_kuiper_prefix              = "${local.primary_resource_prefix}${var.app_prefixes.client.kuiper}"
  primary_mpsql_prefix               = "${local.primary_resource_prefix}${var.app_prefixes.client.mpsql}"
  primary_mychart_prefix             = "${local.primary_resource_prefix}${var.app_prefixes.client.mychart}"
  primary_sts_prefix                 = "${local.primary_resource_prefix}${var.app_prefixes.client.sts}"
  primary_welcome_web_prefix         = "${local.primary_resource_prefix}${var.app_prefixes.client.welcome_web}"
  primary_citrix_cc_prefix           = "${local.primary_resource_prefix}${var.app_prefixes.client.citrix_cc}"
  primary_citrix_vda_prefix          = "${local.primary_resource_prefix}${var.app_prefixes.client.citrix_vda}"
  primary_willow_prefix              = "${local.primary_resource_prefix}${var.app_prefixes.client.willow}"
  primary_image_exchange_prefix      = "${local.primary_resource_prefix}${var.app_prefixes.client.image_exchange}"
  primary_odb_prefix                 = "${local.primary_resource_prefix}${var.app_prefixes.odb.odb}"
  primary_odb_ecp_app_prefix         = "${local.primary_resource_prefix}${var.app_prefixes.odb.odb_ecp_app}"
  primary_odb_ecp_util_prefix        = "${local.primary_resource_prefix}${var.app_prefixes.odb.odb_ecp_util}"
  primary_rpt_prefix                 = "${local.primary_resource_prefix}${var.app_prefixes.odb.rpt}"
  primary_rpt_ecp_util_prefix        = "${local.primary_resource_prefix}${var.app_prefixes.odb.rpt_ecp_util}"
  primary_caboodle_db_prefix         = "${local.primary_resource_prefix}${var.app_prefixes.cogito.caboodle_db}"
  primary_clarity_db_prefix          = "${local.primary_resource_prefix}${var.app_prefixes.cogito.clarity_db}"
  primary_caboodle_console_prefix    = "${local.primary_resource_prefix}${var.app_prefixes.cogito.caboodle_console}"
  primary_clarity_console_prefix     = "${local.primary_resource_prefix}${var.app_prefixes.cogito.clarity_console}"
  primary_caboodle_etl_prefix        = "${local.primary_resource_prefix}${var.app_prefixes.cogito.caboodle_etl}"
  primary_slicerdicer_prefix         = "${local.primary_resource_prefix}${var.app_prefixes.cogito.slicerdicer}"
  primary_birestful_prefix           = "${local.primary_resource_prefix}${var.app_prefixes.cogito.bi_restful}"
  primary_cubes_prefix               = "${local.primary_resource_prefix}${var.app_prefixes.cogito.cubes}"
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
