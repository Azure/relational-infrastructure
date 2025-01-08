module "primary_dmz_vnet" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  address_space       = [var.primary_network_address_spaces.dmz]
  location            = var.primary_location
  resource_group_name = local.primary_networks_rg_name
  name                = local.primary_dmz_vnet_name
  subnets             = local.primary_dmz_subnets
}

module "primary_shared_infrastructure_vnet" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  address_space       = [var.primary_network_address_spaces.shared_infrastructure]
  location            = var.primary_location
  resource_group_name = local.primary_networks_rg_name
  name                = local.primary_shared_infrastructure_vnet_name
  subnets             = local.primary_shared_infrastructure_subnets
}

module "primary_main_vnet" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  address_space       = [var.primary_network_address_spaces.main]
  location            = var.primary_location
  resource_group_name = local.primary_networks_rg_name
  name                = local.primary_main_vnet_name
  subnets             = local.primary_main_subnets
}

module "primary_hyperspace_vnet" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  address_space       = [var.primary_network_address_spaces.hyperspace]
  location            = var.primary_location
  resource_group_name = local.primary_networks_rg_name
  name                = local.primary_hyperspace_vnet_name
  subnets             = local.primary_hyperspace_subnets
}

module "primary_hyperspace_web_vnet" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  address_space       = [var.primary_network_address_spaces.hyperspace_web]
  location            = var.primary_location
  resource_group_name = local.primary_networks_rg_name
  name                = local.primary_hyperspace_web_vnet_name
  subnets             = local.primary_hyperspace_web_subnets
}

resource "azurerm_virtual_network_peering" "peer_primary_hyperspace_to_hsw" {
  name                      = "peer-${module.primary_hyperspace_vnet.name}-to-${module.primary_hyperspace_web_vnet.name}"
  resource_group_name       = local.primary_networks_rg_name
  virtual_network_name      = module.primary_hyperspace_vnet.name
  remote_virtual_network_id = module.primary_hyperspace_web_vnet.resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_hsw_to_hyperspace" {
  name                      = "peer-${module.primary_hyperspace_web_vnet.name}-to-${module.primary_hyperspace_vnet.name}"
  resource_group_name       = local.primary_networks_rg_name
  virtual_network_name      = module.primary_hyperspace_web_vnet.name
  remote_virtual_network_id = module.primary_hyperspace_vnet.resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_hyperspace_to_main" {
  name                      = "peer-${module.primary_hyperspace_vnet.name}-to-${module.primary_main_vnet.name}"
  resource_group_name       = local.primary_networks_rg_name
  virtual_network_name      = module.primary_hyperspace_vnet.name
  remote_virtual_network_id = module.primary_main_vnet.resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_main_to_hyperspace" {
  name                      = "peer-${module.primary_main_vnet.name}-to-${module.primary_hyperspace_vnet.name}"
  resource_group_name       = local.primary_networks_rg_name
  virtual_network_name      = module.primary_main_vnet.name
  remote_virtual_network_id = module.primary_hyperspace_vnet.resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_hyperspace_to_shared_infrastructure" {
  name                      = "peer-${module.primary_hyperspace_vnet.name}-to-${module.primary_shared_infrastructure_vnet.name}"
  resource_group_name       = local.primary_networks_rg_name
  virtual_network_name      = module.primary_hyperspace_vnet.name
  remote_virtual_network_id = module.primary_shared_infrastructure_vnet.resource_id
}

resource "azurerm_virtual_network_peering" "peer_primary_shared_infrastructure_to_hyperspace" {
  name                      = "peer-${module.primary_shared_infrastructure_vnet.name}-to-${module.primary_hyperspace_vnet.name}"
  resource_group_name       = local.primary_networks_rg_name
  virtual_network_name      = module.primary_shared_infrastructure_vnet.name
  remote_virtual_network_id = module.primary_hyperspace_vnet.resource_id
}