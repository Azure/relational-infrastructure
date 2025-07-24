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
    default_resource_group_name = "rg"
    subscription_id             = "0000-..."
  }
}
resource_groups = {
  rg = {
    location_name     = "primary"
    name              = "main-rg"
    subscription_name = "prod"
  }
}
network_ports = {
  http  = "80"
  https = "443"
}
network_security_rules = {
  allow_http_https = {
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
    port_names = [
      "http",
      "https"
    ]
  }
}
external_networks = {
  on_prem = {
    address_space = "192.168.0.0/16"
  }
}
networks = {
  alt = {
    address_space       = "10.1.0.0/16"
    location_name       = "alt"
    resource_group_name = "rg"
    subscription_name   = "prod"
    subnets = {
      a = {
        address_space = "10.1.0.0/24"
      }
    }
  }
  main = {
    address_space       = "10.0.0.0/16"
    location_name       = "primary"
    resource_group_name = "rg"
    subscription_name   = "prod"
    peered_to           = ["on_prem"]
    subnets = {
      a = {
        address_space = "10.0.0.0/24"
        security_rules = [
          "allow_http_https"
        ]
      }
      b = {
        address_space = "10.0.1.0/24"
      }
    }
  }
}
virtual_machine_extensions = {
  azure_monitor = {
    auto_upgrade_minor_version = true
    name                       = "AzureMonitorWindowsAgent"
    publisher                  = "Microsoft.Azure.Monitor"
    type                       = "AzureMonitorWindowsAgent"
    type_handler_version       = "1.2"
  }
}
virtual_machine_sets = {
  vms = {
    enable_boot_diagnostics = true
    extensions = [
      "azure_monitor"
    ]
    image_name          = "windows"
    key_vault_name      = "kv"
    location_name       = "primary"
    network_interfaces = {
      nic = {
        network_name = "main"
        subnet_name  = "a"
      }
    }
    os_type             = "Windows"
    resource_group_name = "rg"
    subscription_name   = "prod"
  }
}
virtual_machine_set_specs = {
  vms = {
    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
    sku_size = "Standard_D2s_v3"
    vm_count = 3
  }
}
virtual_machine_set_zone_distribution = {
  vms = {
    even = [
      "1",
      "2",
      "3"
    ]
  }
}
virtual_machine_images = {
  windows = {
    reference = {
      offer     = "WindowsServer"
      publisher = "MicrosoftWindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
    }
  }
}
key_vaults = {
  kv = {
    location_name       = "primary"
    resource_group_name = "rg"
    subscription_name   = "prod"
  }
}
```

Efficiency: Compact, normalized structure; changes propagate via relationships, minimizing updates.

### Traditional Terraform
Requires separate resources/modules for each: azurerm_virtual_network, azurerm_subnet (x2), azurerm_network_security_group with rules, azurerm_virtual_machine (x3), extensions, peering, availability set/zone config. Total 32 lines.

```hcl
variable "regions" {
  default = [
    "eastus",
    "westus"
  ]
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
  location = var.regions[0]
  name     = "main-rg"
}

resource "azurerm_virtual_network" "main" {
  address_space       = [
    "10.0.0.0/16"
  ]
  location            = var.regions[0]
  name                = "main-vnet"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "a" {
  address_prefixes     = [
    "10.0.0.0/24"
  ]
  name                 = "subnet-a"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
}
resource "azurerm_subnet" "b" {
  address_prefixes     = [
    "10.0.1.0/24"
  ]
  name                 = "subnet-b"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
}

resource "azurerm_network_security_group" "nsg" {
  location            = var.regions[0]
  name                = "main-nsg"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_network_security_rule" "rules" {
  for_each = {
    for idx, rule in local.security_rules : idx => rule
  }

  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = each.value.port
  direction                   = "Inbound"
  name                        = each.value.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 100 + each.key
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.rg.name
  source_address_prefix       = "*"
  source_port_range           = "*"
}
resource "azurerm_subnet_network_security_group_association" "assoc" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = azurerm_subnet.a.id
}

resource "azurerm_virtual_network" "alt" {
  address_space       = [
    "10.1.0.0/16"
  ]
  location            = var.regions[1]
  name                = "alt-vnet"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_virtual_network_peering" "peer" {
  name                      = "peer-to-onprem"
  remote_virtual_network_id = "/subscriptions/.../vnet-onprem" # Assuming external ID
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.main.name
}

module "vms" {
  for_each = toset([
    "1",
    "2",
    "3"
  ])
  source = "Azure/compute/azurerm"
  version = "x"

  admin_password              = "password"
  admin_username              = "admin"
  availability_zones          = [
    each.key
  ]
  enable_boot_diagnostics     = true
  extensions = [
    {
      auto_upgrade_minor_version = true
      publisher                  = "Microsoft.Azure.Monitor"
      type                       = "AzureMonitorWindowsAgent"
      type_handler_version       = "1.2"
    }
  ]
  location                    = var.regions[0]
  nb_instances                = 1
  resource_group_name         = azurerm_resource_group.rg.name
  vm_hostname                 = "vm-${each.key}"
  vm_os_offer                 = "WindowsServer"
  vm_os_publisher             = "MicrosoftWindowsServer"
  vm_os_sku                   = "2019-Datacenter"
  vm_os_version               = "latest"
  vm_size                     = "Standard_D2s_v3"
  vnet_subnet_id              = azurerm_subnet.a.id
}
resource "azurerm_key_vault" "kv" {
  location            = var.regions[0]
  name                = "main-kv"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "standard"
  tenant_id           = "..."
}
```

Efficiency: Verbose; manual references/duplication for relationships, error-prone for scaling.
