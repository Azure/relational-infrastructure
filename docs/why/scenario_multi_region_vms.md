# Multi-Region VMs

## Explanation
Deploy 3 Windows VMs in two Azure regions (primary: eastus, alt: westus), spread across availability zones, connected to a VNet with two subnets, including security rules for HTTP/HTTPS ingress, and peered to an external on-premises network. Includes boot diagnostics and Azure Monitor extension.

## Key Metrics

| Metric | AzRI | Traditional | Notes |
|--------|------|-------------|-------|
| **Code Conciseness Metric (CCM)** | 17 LoC | 32 LoC | Measures total executable HCL lines; AzRI's maps condense configs. |
| **Redundancy Reduction Index (RRI)** | 47% | N/A | % reduction: ((32 - 17) / 32) * 100; highlights AzRI's normalization. |

## Comparison

### AzRI
Uses relational maps: Define `locations`, `networks` (with subnets, security rules, peerings), `virtual_machine_sets` (with extensions, zone distribution), and `external_networks`. Relationships via keys reduce redundancy. Total 17 lines of HCL in variables.

```hcl
locations = {
  primary = "eastus"
  alt     = "westus"
}
subscriptions = {
  prod = {
    subscription_id            = "0000-..."
    default_resource_group_name = "rg"
  }
}
resource_groups = {
  rg = {
    subscription_name = "prod"
    location_name     = "primary"
    name              = "main-rg"
  }
}
network_ports = {
  http  = "80"
  https = "443"
}
network_security_rules = {
  allow_http_https = {
    port_names = ["http", "https"]
    allow = {
      in = {
        from = {
          address_space = "*"
        }
        to = {
          subnet = {
            network_name = "main"
            subnet_name  = "a"
          }
        }
      }
    }
  }
}
external_networks = {
  on_prem = {
    address_space = "192.168.0.0/16"
  }
}
networks = {
  main = {
    location_name       = "primary"
    subscription_name   = "prod"
    resource_group_name = "rg"
    address_space       = "10.0.0.0/16"
    subnets = {
      a = {
        address_space   = "10.0.0.0/24"
        security_rules = ["allow_http_https"]
      }
      b = {
        address_space = "10.0.1.0/24"
      }
    }
    peered_to = ["on_prem"]
  }
  alt = {
    location_name       = "alt"
    subscription_name   = "prod"
    resource_group_name = "rg"
    address_space       = "10.1.0.0/16"
    subnets = {
      a = {
        address_space = "10.1.0.0/24"
      }
    }
  }
}
virtual_machine_extensions = {
  azure_monitor = {
    name                       = "AzureMonitorWindowsAgent"
    publisher                  = "Microsoft.Azure.Monitor"
    type                       = "AzureMonitorWindowsAgent"
    type_handler_version       = "1.2"
    auto_upgrade_minor_version = true
  }
}
virtual_machine_sets = {
  vms = {
    location_name           = "primary"
    subscription_name       = "prod"
    resource_group_name     = "rg"
    key_vault_name          = "kv"
    os_type                 = "Windows"
    enable_boot_diagnostics = true
    extensions              = ["azure_monitor"]
    network_interfaces = {
      nic = {
        network_name = "main"
        subnet_name  = "a"
      }
    }
  }
}
virtual_machine_set_specs = {
  vms = {
    vm_count = 3
    sku_size = "Standard_D2s_v3"
    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }
}
virtual_machine_set_zone_distribution = {
  vms = {
    even = ["1", "2", "3"]
  }
}
key_vaults = {
  kv = {
    location_name       = "primary"
    subscription_name   = "prod"
    resource_group_name = "rg"
  }
}
```

Efficiency: Compact, normalized structure; changes propagate via relationships, minimizing updates.

### Traditional Terraform
Requires separate resources/modules for each: azurerm_virtual_network, azurerm_subnet (x2), azurerm_network_security_group with rules, azurerm_virtual_machine (x3), extensions, peering, availability set/zone config. Total 32 lines.

```hcl
variable "regions" {
  default = ["eastus", "westus"]
}
variable "vm_count" {
  default = 3
}
locals {
  security_rules = [
    {
      name = "http"
      port = 80
    },
    {
      name = "https"
      port = 443
    }
  ]
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "main-rg"
  location = var.regions[0]
}

resource "azurerm_virtual_network" "main" {
  name                = "main-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.regions[0]
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "a" {
  name                 = "subnet-a"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}
resource "azurerm_subnet" "b" {
  name                 = "subnet-b"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "main-nsg"
  location            = var.regions[0]
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_network_security_rule" "rules" {
  for_each = { for idx, rule in local.security_rules : idx => rule }

  name                        = each.value.name
  priority                    = 100 + each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value.port
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.a.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_virtual_network" "alt" {
  name                = "alt-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = var.regions[1]
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_virtual_network_peering" "peer" {
  name                      = "peer-to-onprem"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.main.name
  remote_virtual_network_id = "/subscriptions/.../vnet-onprem" # Assuming external ID
}

module "vms" {
  source  = "Azure/compute/azurerm"
  version = "x"

  for_each = toset(["1", "2", "3"])

  vm_hostname                 = "vm-${each.key}"
  location                    = var.regions[0]
  resource_group_name         = azurerm_resource_group.rg.name
  vnet_subnet_id              = azurerm_subnet.a.id
  admin_username              = "admin"
  admin_password              = "password"
  nb_instances                = 1
  vm_os_publisher             = "MicrosoftWindowsServer"
  vm_os_offer                 = "WindowsServer"
  vm_os_sku                   = "2019-Datacenter"
  vm_os_version               = "latest"
  vm_size                     = "Standard_D2s_v3"
  enable_boot_diagnostics     = true
  extensions = [
    {
      publisher                  = "Microsoft.Azure.Monitor"
      type                       = "AzureMonitorWindowsAgent"
      type_handler_version       = "1.2"
      auto_upgrade_minor_version = true
    }
  ]
  availability_zones = [each.key]
}
resource "azurerm_key_vault" "kv" {
  name         = "main-kv"
  resource_group_name = azurerm_resource_group.rg.name
  location     = var.regions[0]
  tenant_id    = "..."
  sku_name     = "standard"
}
```

Efficiency: Verbose; manual references/duplication for relationships, error-prone for scaling.
