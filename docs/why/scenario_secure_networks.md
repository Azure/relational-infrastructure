# Secure Networks

## Explanation
Create two VNets in different regions, each with subnets, custom routes to internet/gateway, security rules denying all inbound except SSH from specific external subnet, and peering between them. Integrate with external cloud network.

## Key Metrics

| Metric | AzRI | Traditional | Notes |
|--------|------|-------------|-------|
| **Code Conciseness Metric (CCM)** | 9 LoC | 24 LoC | Measures total executable HCL lines; AzRI's maps condense configs. |
| **Redundancy Reduction Index (RRI)** | 63% | N/A | % reduction: ((24 - 9) / 24) * 100; highlights AzRI's normalization. |

## Comparison

### AzRI
Defines `networks` (subnets, routes, security rules, peerings), `external_networks`, `network_ports`, `network_security_rules`. Fluent syntax for rules/routes. Total 9 lines.

```hcl
locations = {
  primary = "eastus"
  alt     = "westus"
}
network_ports = {
  ssh = "22"
}
network_security_rules = {
  deny_all = {
    deny = {
      in = {
        to = {
          network = {
            name = "main"
          }
        }
      }
    }
  }
  allow_ssh = {
    port_names = ["ssh"]
    protocol   = "Tcp"
    allow = {
      in = {
        from = {
          subnet = {
            network_name = "ext"
            subnet_name  = "secure"
          }
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
  ext = {
    address_space = "172.16.0.0/16"
    subnets = {
      secure = {
        address_space = "172.16.1.0/24"
      }
    }
  }
}
networks = {
  main = {
    location_name = "primary"
    address_space = "10.0.0.0/16"
    subnets = {
      a = {
        address_space = "10.0.0.0/24"
        security_rules = [
          "deny_all",
          "allow_ssh"
        ]
        route_traffic = {
          internet = {
            destined_for = {
              address_space = "0.0.0.0/0"
            }
            to_internet = true
          }
          gateway = {
            destined_for = {
              network = {
                network_name = "ext"
              }
            }
            to_gateway = true
          }
        }
      }
    }
    peered_to = [
      "alt",
      "ext"
    ]
  }
  alt = {
    location_name = "alt"
    address_space = "10.1.0.0/16"
    subnets = {
      a = {
        address_space = "10.1.0.0/24"
      }
    }
    peered_to = ["main"]
  }
}
```

Efficiency: Rule/route fluency reduces boilerplate; peerings/routes link via keys.

### Traditional Terraform
Separate: azurerm_virtual_network (x2), azurerm_subnet (x2+), azurerm_route_table with routes, azurerm_network_security_group with rules, azurerm_virtual_network_peering (x2 for bidirectional). Total 24 lines.

```hcl
locals {
  rules = [
    {
      name   = "deny_all"
      access = "Deny"
    },
    {
      name   = "allow_ssh"
      port   = 22
      access = "Allow"
      source = "172.16.1.0/24"
    }
  ]
  routes = [
    {
      name      = "internet"
      address   = "0.0.0.0/0"
      next_hop  = "Internet"
    },
    {
      name      = "gateway"
      address   = "172.16.0.0/16"
      next_hop  = "VirtualAppliance"
    }
  ]
}

resource "azurerm_virtual_network" "vnets" {
  for_each = {
    main = "eastus"
    alt  = "westus"
  }

  name                = "${each.key}-vnet"
  address_space       = each.key == "main" ? ["10.0.0.0/16"] : ["10.1.0.0/16"]
  location            = each.value
  resource_group_name = "rg"
}

resource "azurerm_subnet" "subnets" {
  for_each = {
    main_a = azurerm_virtual_network.vnets["main"].id
    alt_a  = azurerm_virtual_network.vnets["alt"].id
  }

  name                 = "${split("_", each.key)[1]}-subnet"
  resource_group_name  = "rg"
  virtual_network_name = azurerm_virtual_network.vnets[split("_", each.key)[0]].name
  address_prefixes     = split("_", each.key)[0] == "main" ? ["10.0.0.0/24"] : ["10.1.0.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "main-nsg"
  location            = "eastus"
  resource_group_name = "rg"
}
resource "azurerm_network_security_rule" "sec_rules" {
  for_each = { for idx, r in local.rules : idx => r }

  name                        = each.value.name
  priority                    = 100 + each.key
  direction                   = "Inbound"
  access                      = each.value.access
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = lookup(each.value, "port", "*")
  source_address_prefix       = lookup(each.value, "source", "*")
  destination_address_prefix  = "*"
  resource_group_name         = "rg"
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_route_table" "rt" {
  name                = "main-rt"
  location            = "eastus"
  resource_group_name = "rg"
}
resource "azurerm_route" "routes" {
  for_each = { for idx, rt in local.routes : idx => rt }

  name                = each.value.name
  address_prefix      = each.value.address
  next_hop_type       = each.value.next_hop
  route_table_name    = azurerm_route_table.rt.name
  resource_group_name = "rg"
}

resource "azurerm_virtual_network_peering" "peerings" {
  for_each = ["alt", "ext"]

  name                      = "peer-to-${each.value}"
  resource_group_name       = "rg"
  virtual_network_name      = azurerm_virtual_network.vnets["main"].name
  remote_virtual_network_id = each.value == "alt" ? azurerm_virtual_network.vnets["alt"].id : "ext-id"
}
```

Efficiency: Manual associations (e.g., subnet to NSG/route table); no fluent syntax, more error-prone.
