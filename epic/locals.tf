locals {
  alt_resource_prefix     = "${var.resource_prefix}alt"
  primary_resource_prefix = "${var.resource_prefix}prm"
}

locals {
  alt_networks_rg_name     = "${local.alt_resource_prefix}networks"
  primary_networks_rg_name = "${local.primary_resource_prefix}networks"
}

locals {
  alt_dmz_vnet_name                       = "${local.alt_resource_prefix}dmznet01"
  alt_shared_infrastructure_vnet_name     = "${local.alt_resource_prefix}sifnet01"
  alt_main_vnet_name                      = "${local.alt_resource_prefix}mainet01"
  alt_hyperspace_vnet_name                = "${local.alt_resource_prefix}hspnet01"
  alt_hyperspace_web_vnet_name            = "${local.alt_resource_prefix}hswnet01"
  primary_dmz_vnet_name                   = "${local.primary_resource_prefix}dmznet01"
  primary_shared_infrastructure_vnet_name = "${local.primary_resource_prefix}sifnet01"
  primary_main_vnet_name                  = "${local.primary_resource_prefix}mainet01"
  primary_hyperspace_vnet_name            = "${local.primary_resource_prefix}hspnet01"
  primary_hyperspace_web_vnet_name        = "${local.primary_resource_prefix}hswnet01"
}

locals {
  alt_subnet_size_bits = {
    dmz = {
      firewall   = 8
      production = 8
    }
    shared_infrastructure = {
      gateway    = 8
      management = 8
    }
    main = {
      odb    = 8
      wss    = 8
      cogito = 8
    }
    hyperspace = {
      hyperspace = 8
    }
    hyperspace_web = {
      hyperspace_web = 8
    }
  }

  primary_subnet_size_bits = {
    dmz = {
      firewall   = 8
      production = 8
    }
    shared_infrastructure = {
      gateway    = 8
      management = 8
    }
    main = {
      odb    = 8
      wss    = 8
      cogito = 8
    }
    hyperspace = {
      hyperspace = 8
    }
    hyperspace_web = {
      hyperspace_web = 8
    }
  }
}

locals {
  alt_dmz_vnet_subnet_spaces = cidrsubnets(
    var.alt_network_address_spaces.dmz,
    local.alt_subnet_size_bits.dmz.firewall,
    local.alt_subnet_size_bits.dmz.production
  )

  alt_shared_infrastructure_vnet_subnet_spaces = cidrsubnets(
    var.alt_network_address_spaces.shared_infrastructure,
    local.alt_subnet_size_bits.shared_infrastructure.gateway,
    local.alt_subnet_size_bits.shared_infrastructure.management
  )

  alt_main_vnet_subnet_spaces = cidrsubnets(
    var.alt_network_address_spaces.main,
    local.alt_subnet_size_bits.main.odb,
    local.alt_subnet_size_bits.main.wss,
    local.alt_subnet_size_bits.main.cogito
  )

  alt_hyperspace_vnet_subnet_spaces = cidrsubnets(
    var.alt_network_address_spaces.hyperspace,
    local.alt_subnet_size_bits.hyperspace.hyperspace
  )

  alt_hyperspace_web_vnet_subnet_spaces = cidrsubnets(
    var.alt_network_address_spaces.hyperspace_web,
    local.alt_subnet_size_bits.hyperspace_web.hyperspace_web
  )

  primary_dmz_vnet_subnet_spaces = cidrsubnets(
    var.primary_network_address_spaces.dmz,
    local.primary_subnet_size_bits.dmz.firewall,
    local.primary_subnet_size_bits.dmz.production
  )

  primary_shared_infrastructure_vnet_subnet_spaces = cidrsubnets(
    var.primary_network_address_spaces.shared_infrastructure,
    local.primary_subnet_size_bits.shared_infrastructure.gateway,
    local.primary_subnet_size_bits.shared_infrastructure.management
  )

  primary_main_vnet_subnet_spaces = cidrsubnets(
    var.primary_network_address_spaces.main,
    local.primary_subnet_size_bits.main.odb,
    local.primary_subnet_size_bits.main.wss,
    local.primary_subnet_size_bits.main.cogito
  )

  primary_hyperspace_vnet_subnet_spaces = cidrsubnets(
    var.primary_network_address_spaces.hyperspace,
    local.primary_subnet_size_bits.hyperspace.hyperspace
  )

  primary_hyperspace_web_vnet_subnet_spaces = cidrsubnets(
    var.primary_network_address_spaces.hyperspace_web,
    local.primary_subnet_size_bits.hyperspace_web.hyperspace_web
  )
}

locals {
  alt_dmz_subnets = {
    firewall = {
      name             = "FirewallSubnet"
      address_prefixes = [local.alt_dmz_vnet_subnet_spaces[0]]
    }
    production = {
      name             = "Production"
      address_prefixes = [local.alt_dmz_vnet_subnet_spaces[1]]
    }
  }

  alt_shared_infrastructure_subnets = {
    gateway = {
      name             = "GatewaySubnet"
      address_prefixes = [local.alt_shared_infrastructure_vnet_subnet_spaces[0]]
    }
    management = {
      name             = "Management"
      address_prefixes = [local.alt_shared_infrastructure_vnet_subnet_spaces[1]]
    }
  }

  alt_main_subnets = {
    odb = {
      name             = "ODB"
      address_prefixes = [local.alt_main_vnet_subnet_spaces[0]]
    }
    wss = {
      name             = "WSS"
      address_prefixes = [local.alt_main_vnet_subnet_spaces[1]]
    }
    cogito = {
      name             = "Cogito"
      address_prefixes = [local.alt_main_vnet_subnet_spaces[2]]
    }
  }

  alt_hyperspace_subnets = {
    hyperspace = {
      name             = "Hyperspace"
      address_prefixes = [local.alt_hyperspace_vnet_subnet_spaces[0]]
    }
  }

  alt_hyperspace_web_subnets = {
    hyperspace_web = {
      name             = "HyperspaceWeb"
      address_prefixes = [local.alt_hyperspace_web_vnet_subnet_spaces[0]]
    }
  }

  primary_dmz_subnets = {
    firewall = {
      name             = "FirewallSubnet"
      address_prefixes = [local.primary_dmz_vnet_subnet_spaces[0]]
    }
    production = {
      name             = "Production"
      address_prefixes = [local.primary_dmz_vnet_subnet_spaces[1]]
    }
  }

  primary_shared_infrastructure_subnets = {
    gateway = {
      name             = "GatewaySubnet"
      address_prefixes = [local.primary_shared_infrastructure_vnet_subnet_spaces[0]]
    }
    management = {
      name             = "Management"
      address_prefixes = [local.primary_shared_infrastructure_vnet_subnet_spaces[1]]
    }
  }

  primary_main_subnets = {
    odb = {
      name             = "ODB"
      address_prefixes = [local.primary_main_vnet_subnet_spaces[0]]
    }
    wss = {
      name             = "WSS"
      address_prefixes = [local.primary_main_vnet_subnet_spaces[1]]
    }
    cogito = {
      name             = "Cogito"
      address_prefixes = [local.primary_main_vnet_subnet_spaces[2]]
    }
  }

  primary_hyperspace_subnets = {
    hyperspace = {
      name             = "Hyperspace"
      address_prefixes = [local.primary_hyperspace_vnet_subnet_spaces[0]]
    }
  }

  primary_hyperspace_web_subnets = {
    hyperspace_web = {
      name             = "HyperspaceWeb"
      address_prefixes = [local.primary_hyperspace_web_vnet_subnet_spaces[0]]
    }
  }
}
