module "primary_network_resource_group" {
  count    = local.deploy_primary ? 1 : 0
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  location = var.primary_location
  name     = local.primary_networks_rg_name

  tags = {
    description = "Primary Region Network Resources"
  }
}

module "primary_dmz_vnet" {
  count               = local.deploy_primary ? 1 : 0
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  address_space       = [var.primary_networks.dmz.space]
  location            = var.primary_location
  resource_group_name = module.primary_network_resource_group[0].name
  name                = local.primary_dmz_vnet_name
  subnets             = local.primary_dmz_vnet_subnets

  tags = {
    description = "Primary Region DMZ Network"
  }
}

module "primary_shared_infra_vnet" {
  count               = local.deploy_primary ? 1 : 0
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  address_space       = [var.primary_networks.shared_infra.space]
  location            = var.primary_location
  resource_group_name = module.primary_network_resource_group[0].name
  name                = local.primary_shared_infra_vnet_name
  subnets             = local.primary_shared_infra_vnet_subnets

  tags = {
    description = "Primary Region Shared Infrastructure Network"
  }
}

module "primary_main_vnet" {
  count               = local.deploy_primary ? 1 : 0
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  address_space       = [var.primary_networks.main.space]
  location            = var.primary_location
  resource_group_name = module.primary_network_resource_group[0].name
  name                = local.primary_main_vnet_name
  subnets             = local.primary_main_vnet_subnets

  tags = {
    description = "Primary Region Main Network"
  }
}

module "primary_hyperspace_vnet" {
  count               = local.deploy_primary ? 1 : 0
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  address_space       = [var.primary_networks.hyperspace.space]
  location            = var.primary_location
  resource_group_name = module.primary_network_resource_group[0].name
  name                = local.primary_hyperspace_vnet_name
  subnets             = local.primary_hyperspace_vnet_subnets

  tags = {
    description = "Primary Region Hyperspace Network"
  }
}

module "primary_hyperspace_web_vnet" {
  count               = local.deploy_primary ? 1 : 0
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  address_space       = [var.primary_networks.hyperspace_web.space]
  location            = var.primary_location
  resource_group_name = module.primary_network_resource_group[0].name
  name                = local.primary_hyperspace_web_vnet_name
  subnets             = local.primary_hyperspace_web_vnet_subnets

  tags = {
    description = "Primary Region Hyperspace Web Network"
  }
}

resource "azurerm_virtual_network_peering" "peer_primary_hyperspace_to_hsw" {
  count                     = local.deploy_primary ? 1 : 0
  name                      = "peer-${module.primary_hyperspace_vnet[0].name}-to-${module.primary_hyperspace_web_vnet[0].name}"
  resource_group_name       = module.primary_network_resource_group[0].name
  virtual_network_name      = module.primary_hyperspace_vnet[0].name
  remote_virtual_network_id = module.primary_hyperspace_web_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_hsw_to_hyperspace" {
  count                     = local.deploy_primary ? 1 : 0
  name                      = "peer-${module.primary_hyperspace_web_vnet[0].name}-to-${module.primary_hyperspace_vnet[0].name}"
  resource_group_name       = module.primary_network_resource_group[0].name
  virtual_network_name      = module.primary_hyperspace_web_vnet[0].name
  remote_virtual_network_id = module.primary_hyperspace_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_hyperspace_to_main" {
  count                     = local.deploy_primary ? 1 : 0
  name                      = "peer-${module.primary_hyperspace_vnet[0].name}-to-${module.primary_main_vnet[0].name}"
  resource_group_name       = module.primary_network_resource_group[0].name
  virtual_network_name      = module.primary_hyperspace_vnet[0].name
  remote_virtual_network_id = module.primary_main_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_main_to_hyperspace" {
  count                     = local.deploy_primary ? 1 : 0
  name                      = "peer-${module.primary_main_vnet[0].name}-to-${module.primary_hyperspace_vnet[0].name}"
  resource_group_name       = module.primary_network_resource_group[0].name
  virtual_network_name      = module.primary_main_vnet[0].name
  remote_virtual_network_id = module.primary_hyperspace_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_hyperspace_to_shared_infra" {
  count                     = local.deploy_primary ? 1 : 0
  name                      = "peer-${module.primary_hyperspace_vnet[0].name}-to-${module.primary_shared_infra_vnet[0].name}"
  resource_group_name       = module.primary_network_resource_group[0].name
  virtual_network_name      = module.primary_hyperspace_vnet[0].name
  remote_virtual_network_id = module.primary_shared_infra_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_shared_infra_to_hyperspace" {
  count                     = local.deploy_primary ? 1 : 0
  name                      = "peer-${module.primary_shared_infra_vnet[0].name}-to-${module.primary_hyperspace_vnet[0].name}"
  resource_group_name       = module.primary_network_resource_group[0].name
  virtual_network_name      = module.primary_shared_infra_vnet[0].name
  remote_virtual_network_id = module.primary_hyperspace_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_hsw_to_main" {
  count                     = local.deploy_primary ? 1 : 0
  name                      = "peer-${module.primary_hyperspace_web_vnet[0].name}-to-${module.primary_main_vnet[0].name}"
  resource_group_name       = module.primary_network_resource_group[0].name
  virtual_network_name      = module.primary_hyperspace_web_vnet[0].name
  remote_virtual_network_id = module.primary_main_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_main_to_hsw" {
  count                     = local.deploy_primary ? 1 : 0
  name                      = "peer-${module.primary_main_vnet[0].name}-to-${module.primary_hyperspace_web_vnet[0].name}"
  resource_group_name       = module.primary_network_resource_group[0].name
  virtual_network_name      = module.primary_main_vnet[0].name
  remote_virtual_network_id = module.primary_hyperspace_web_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_hsw_to_shared_infra" {
  count                     = local.deploy_primary ? 1 : 0
  name                      = "peer-${module.primary_hyperspace_web_vnet[0].name}-to-${module.primary_shared_infra_vnet[0].name}"
  resource_group_name       = module.primary_network_resource_group[0].name
  virtual_network_name      = module.primary_hyperspace_web_vnet[0].name
  remote_virtual_network_id = module.primary_shared_infra_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_shared_infra_to_hsw" {
  count                     = local.deploy_primary ? 1 : 0
  name                      = "peer-${module.primary_shared_infra_vnet[0].name}-to-${module.primary_hyperspace_web_vnet[0].name}"
  resource_group_name       = module.primary_network_resource_group[0].name
  virtual_network_name      = module.primary_shared_infra_vnet[0].name
  remote_virtual_network_id = module.primary_hyperspace_web_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_main_to_shared_infra" {
  count                     = local.deploy_primary ? 1 : 0
  name                      = "peer-${module.primary_main_vnet[0].name}-to-${module.primary_shared_infra_vnet[0].name}"
  resource_group_name       = module.primary_network_resource_group[0].name
  virtual_network_name      = module.primary_main_vnet[0].name
  remote_virtual_network_id = module.primary_shared_infra_vnet[0].resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_shared_infra_to_main" {
  count                     = local.deploy_primary ? 1 : 0
  name                      = "peer-${module.primary_shared_infra_vnet[0].name}-to-${module.primary_main_vnet[0].name}"
  resource_group_name       = module.primary_network_resource_group[0].name
  virtual_network_name      = module.primary_shared_infra_vnet[0].name
  remote_virtual_network_id = module.primary_main_vnet[0].resource_id
}

