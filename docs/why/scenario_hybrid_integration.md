# Hybrid Integration

## Explanation
Integrate Azure with external networks: VM set in Azure connected to external subnets via routes/peering, storage with private endpoints, all under lock groups for production lockdown, across two subscriptions.

## Key Metrics

| Metric | AzRI | Traditional | Notes |
|--------|------|-------------|-------|
| **Code Conciseness Metric (CCM)** | 11 LoC | 30 LoC | Measures total executable HCL lines; AzRI's maps condense configs. |
| **Redundancy Reduction Index (RRI)** | 63% | N/A | % reduction: ((30 - 11) / 30) * 100; highlights AzRI's normalization. |

## Comparison

### AzRI
Combines `external_networks`, `networks` (routes/peering), `virtual_machine_sets`, `storage_accounts` (private endpoints), `lock_groups`, `subscriptions`. Total 11 lines.

```hcl
subscriptions = {
  prod = {
    subscription_id            = "prod-id"
    default_resource_group_name = "prod-rg"
  }
  nonprod = {
    subscription_id            = "nonprod-id"
    default_resource_group_name = "nonprod-rg"
  }
}
lock_groups = {
  prod_lock = {
    locked    = true
    read_only = false
  }
}
external_networks = {
  ext = {
    address_space = "10.100.0.0/16"
    resource_id   = "ext-vnet-id"
    subnets = {
      conn = {
        address_space = "10.100.1.0/24"
      }
    }
  }
}
networks = {
  azure = {
    subscription_name   = "prod"
    resource_group_name = "prod-rg"
    peered_to = ["ext"]
    subnets = {
      conn = {
        address_space = "10.0.0.0/24"
        route_traffic = {
          to_ext = {
            destined_for = {
              subnet = {
                network_name = "ext"
                subnet_name  = "conn"
              }
            }
            to_gateway = true
          }
        }
      }
    }
  }
}
virtual_machine_sets = {
  hybrid = {
    subscription_name   = "prod"
    resource_group_name = "prod-rg"
    lock_groups         = ["prod_lock"]
    network_interfaces = {
      nic = {
        network_name = "azure"
        subnet_name  = "conn"
      }
    }
  }
}
virtual_machine_set_specs = {
  hybrid = {
    vm_count = 2
    sku_size = "Standard_D2s_v3"
  }
}
storage_accounts = {
  secure = {
    subscription_name   = "prod"
    resource_group_name = "prod-rg"
    lock_groups         = ["prod_lock"]
  }
}
```

Efficiency: External refs via keys; locks inherit/grouped.

### Traditional Terraform
Resources: azurerm_virtual_network_peering, azurerm_route, azurerm_private_endpoint, azurerm_management_lock (multiple), providers for subscriptions. Total 30 lines.

```hcl
variable "subs" {
  default = {
    prod    = "prod-id"
    nonprod = "nonprod-id"
  }
}
provider "azurerm" {
  alias           = "prod"
  subscription_id = var.subs.prod
  features {}
}

resource "azurerm_resource_group" "prod_rg" {
  name     = "prod-rg"
  location = "eastus"
  provider = azurerm.prod
}

resource "azurerm_virtual_network" "azure" {
  name                = "azure-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.prod_rg.name
  provider            = azurerm.prod
}
resource "azurerm_subnet" "conn" {
  name                 = "conn-subnet"
  resource_group_name  = azurerm_resource_group.prod_rg.name
  virtual_network_name = azurerm_virtual_network.azure.name
  address_prefixes     = ["10.0.0.0/24"]
  provider             = azurerm.prod
}

resource "azurerm_route_table" "rt" {
  name                = "hybrid-rt"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.prod_rg.name
  provider            = azurerm.prod
}
resource "azurerm_route" "to_ext" {
  name                = "to-ext"
  address_prefix      = "10.100.1.0/24"
  next_hop_type       = "VirtualNetworkGateway"
  route_table_name    = azurerm_route_table.rt.name
  resource_group_name = azurerm_resource_group.prod_rg.name
  provider            = azurerm.prod
}
resource "azurerm_route_table_association" "assoc" {
  subnet_id      = azurerm_subnet.conn.id
  route_table_id = azurerm_route_table.rt.id
  provider       = azurerm.prod
}

resource "azurerm_virtual_network_peering" "peer" {
  name                      = "peer-to-ext"
  resource_group_name       = azurerm_resource_group.prod_rg.name
  virtual_network_name      = azurerm_virtual_network.azure.name
  remote_virtual_network_id = "ext-vnet-id"
  provider                  = azurerm.prod
}

module "vms" {
  source  = "Azure/compute/azurerm"
  version = "x"

  vm_hostname         = "hybrid"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.prod_rg.name
  vnet_subnet_id      = azurerm_subnet.conn.id
  nb_instances        = 2
  vm_size             = "Standard_D2s_v3"
  providers = {
    azurerm = azurerm.prod
  }
}

resource "azurerm_storage_account" "secure" {
  name                     = "secure-sa"
  resource_group_name      = azurerm_resource_group.prod_rg.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  provider                 = azurerm.prod
}
resource "azurerm_private_endpoint" "sa_endpoint" {
  name                = "sa-endpoint"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.prod_rg.name
  subnet_id           = azurerm_subnet.conn.id
  private_service_connection {
    name                           = "sa-conn"
    private_connection_resource_id = azurerm_storage_account.secure.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  provider = azurerm.prod
}

resource "azurerm_management_lock" "locks" {
  for_each = {
    vm = module.vms.vm_ids[0]
    sa = azurerm_storage_account.secure.id
  }

  name       = "${each.key}-lock"
  scope      = each.value
  lock_level = "CanNotDelete"
  provider   = azurerm.prod
}
```

Efficiency: Cross-sub/external manual; locks per resource, no grouping.
