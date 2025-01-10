module "alt_network_resource_group" {
  count    = local.deploy_alt ? 1 : 0
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  location = var.alt_location
  name     = local.alt_networks_rg_name

  tags = {
    description = "Alternate Region Network Resources"
  }
}

module "alt_dmz_vnet" {
  count               = local.deploy_alt ? 1 : 0
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  address_space       = [var.alt_networks.dmz.space]
  location            = var.alt_location
  resource_group_name = module.alt_network_resource_group[0].name
  name                = local.alt_dmz_vnet_name
  subnets             = local.alt_dmz_vnet_subnets

  tags = {
    description = "Alternate Region DMZ Network"
  }
}

module "alt_shared_infra_vnet" {
  count               = local.deploy_alt ? 1 : 0
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  address_space       = [var.alt_networks.shared_infra.space]
  location            = var.alt_location
  resource_group_name = module.alt_network_resource_group[0].name
  name                = local.alt_shared_infra_vnet_name
  subnets             = local.alt_shared_infra_vnet_subnets

  tags = {
    description = "Alternate Region Shared Infrastructure Network"
  }
}

module "alt_main_vnet" {
  count               = local.deploy_alt ? 1 : 0
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  address_space       = [var.alt_networks.main.space]
  location            = var.alt_location
  resource_group_name = module.alt_network_resource_group[0].name
  name                = local.alt_main_vnet_name
  subnets             = local.alt_main_vnet_subnets

  tags = {
    description = "Alternate Region Main Network"
  }
}

module "alt_hyperspace_vnet" {
  count               = local.deploy_alt ? 1 : 0
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  address_space       = [var.alt_networks.hyperspace.space]
  location            = var.alt_location
  resource_group_name = module.alt_network_resource_group[0].name
  name                = local.alt_hyperspace_vnet_name
  subnets             = local.alt_hyperspace_vnet_subnets

  tags = {
    description = "Alternate Region Hyperspace Network"
  }
}

module "alt_hyperspace_web_vnet" {
  count               = local.deploy_alt ? 1 : 0
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  address_space       = [var.alt_networks.hyperspace_web.space]
  location            = var.alt_location
  resource_group_name = module.alt_network_resource_group[0].name
  name                = local.alt_hyperspace_web_vnet_name
  subnets             = local.alt_hyperspace_web_vnet_subnets

  tags = {
    description = "Alternate Region Hyperspace Web Network"
  }
}

resource "azurerm_virtual_network_peering" "peer_alt_hyperspace_to_hsw" {
  count                     = local.deploy_alt ? 1 : 0
  name                      = "peer-${module.alt_hyperspace_vnet[0].name}-to-${module.alt_hyperspace_web_vnet[0].name}"
  resource_group_name       = module.alt_network_resource_group[0].name
  virtual_network_name      = module.alt_hyperspace_vnet[0].name
  remote_virtual_network_id = module.alt_hyperspace_web_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_alt_hsw_to_hyperspace" {
  count                     = local.deploy_alt ? 1 : 0
  name                      = "peer-${module.alt_hyperspace_web_vnet[0].name}-to-${module.alt_hyperspace_vnet[0].name}"
  resource_group_name       = module.alt_network_resource_group[0].name
  virtual_network_name      = module.alt_hyperspace_web_vnet[0].name
  remote_virtual_network_id = module.alt_hyperspace_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_alt_hyperspace_to_main" {
  count                     = local.deploy_alt ? 1 : 0
  name                      = "peer-${module.alt_hyperspace_vnet[0].name}-to-${module.alt_main_vnet[0].name}"
  resource_group_name       = module.alt_network_resource_group[0].name
  virtual_network_name      = module.alt_hyperspace_vnet[0].name
  remote_virtual_network_id = module.alt_main_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_alt_main_to_hyperspace" {
  count                     = local.deploy_alt ? 1 : 0
  name                      = "peer-${module.alt_main_vnet[0].name}-to-${module.alt_hyperspace_vnet[0].name}"
  resource_group_name       = module.alt_network_resource_group[0].name
  virtual_network_name      = module.alt_main_vnet[0].name
  remote_virtual_network_id = module.alt_hyperspace_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_alt_hyperspace_to_shared_infra" {
  count                     = local.deploy_alt ? 1 : 0
  name                      = "peer-${module.alt_hyperspace_vnet[0].name}-to-${module.alt_shared_infra_vnet[0].name}"
  resource_group_name       = module.alt_network_resource_group[0].name
  virtual_network_name      = module.alt_hyperspace_vnet[0].name
  remote_virtual_network_id = module.alt_shared_infra_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_alt_shared_infra_to_hyperspace" {
  count                     = local.deploy_alt ? 1 : 0
  name                      = "peer-${module.alt_shared_infra_vnet[0].name}-to-${module.alt_hyperspace_vnet[0].name}"
  resource_group_name       = module.alt_network_resource_group[0].name
  virtual_network_name      = module.alt_shared_infra_vnet[0].name
  remote_virtual_network_id = module.alt_hyperspace_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_alt_hsw_to_main" {
  count                     = local.deploy_alt ? 1 : 0
  name                      = "peer-${module.alt_hyperspace_web_vnet[0].name}-to-${module.alt_main_vnet[0].name}"
  resource_group_name       = module.alt_network_resource_group[0].name
  virtual_network_name      = module.alt_hyperspace_web_vnet[0].name
  remote_virtual_network_id = module.alt_main_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_alt_main_to_hsw" {
  count                     = local.deploy_alt ? 1 : 0
  name                      = "peer-${module.alt_main_vnet[0].name}-to-${module.alt_hyperspace_web_vnet[0].name}"
  resource_group_name       = module.alt_network_resource_group[0].name
  virtual_network_name      = module.alt_main_vnet[0].name
  remote_virtual_network_id = module.alt_hyperspace_web_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_alt_hsw_to_shared_infra" {
  count                     = local.deploy_alt ? 1 : 0
  name                      = "peer-${module.alt_hyperspace_web_vnet[0].name}-to-${module.alt_shared_infra_vnet[0].name}"
  resource_group_name       = module.alt_network_resource_group[0].name
  virtual_network_name      = module.alt_hyperspace_web_vnet[0].name
  remote_virtual_network_id = module.alt_shared_infra_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_alt_shared_infra_to_hsw" {
  count                     = local.deploy_alt ? 1 : 0
  name                      = "peer-${module.alt_shared_infra_vnet[0].name}-to-${module.alt_hyperspace_web_vnet[0].name}"
  resource_group_name       = module.alt_network_resource_group[0].name
  virtual_network_name      = module.alt_shared_infra_vnet[0].name
  remote_virtual_network_id = module.alt_hyperspace_web_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_alt_main_to_shared_infra" {
  count                     = local.deploy_alt ? 1 : 0
  name                      = "peer-${module.alt_main_vnet[0].name}-to-${module.alt_shared_infra_vnet[0].name}"
  resource_group_name       = module.alt_network_resource_group[0].name
  virtual_network_name      = module.alt_main_vnet[0].name
  remote_virtual_network_id = module.alt_shared_infra_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_alt_shared_infra_to_main" {
  count                     = local.deploy_alt ? 1 : 0
  name                      = "peer-${module.alt_shared_infra_vnet[0].name}-to-${module.alt_main_vnet[0].name}"
  resource_group_name       = module.alt_network_resource_group[0].name
  virtual_network_name      = module.alt_shared_infra_vnet[0].name
  remote_virtual_network_id = module.alt_main_vnet[0].resource_id
}

