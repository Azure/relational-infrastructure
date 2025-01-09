locals {
  deploy_alt     = tobool(var.alt_location != null)
  deploy_primary = tobool(var.primary_location != null)
}

locals {
  alt_resource_prefix     = "${var.deployment_prefix}a"
  primary_resource_prefix = "${var.deployment_prefix}p"
}

locals {
  alt_networks_rg_name     = "${local.alt_resource_prefix}-network"
  primary_networks_rg_name = "${local.primary_resource_prefix}-network"
}

locals {
  alt_dmz_vnet_name                = "${local.alt_resource_prefix}dmznet01"
  alt_shared_infra_vnet_name       = "${local.alt_resource_prefix}sifnet01"
  alt_main_vnet_name               = "${local.alt_resource_prefix}mainet01"
  alt_hyperspace_vnet_name         = "${local.alt_resource_prefix}hspnet01"
  alt_hyperspace_web_vnet_name     = "${local.alt_resource_prefix}hswnet01"
  primary_dmz_vnet_name            = "${local.primary_resource_prefix}dmznet01"
  primary_shared_infra_vnet_name   = "${local.primary_resource_prefix}sifnet01"
  primary_main_vnet_name           = "${local.primary_resource_prefix}mainet01"
  primary_hyperspace_vnet_name     = "${local.primary_resource_prefix}hspnet01"
  primary_hyperspace_web_vnet_name = "${local.primary_resource_prefix}hswnet01"
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
