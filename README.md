# Epic on Azure Terraform Module Stack

This repo provides a Terraform module stack for deploying Epic on Azure, aligned with the Epic on Azure Well-Architected Framework (WAF) and built on Microsoft’s Azure Verified Modules (AVM).

At the base, the stack uses official AVM resource modules that implement Microsoft’s reliability best practices by default. On top of that, it adds AVM-aligned pattern modules that capture common infrastructure patterns from Epic’s reference architecture—such as role-based virtual machine sets using VMSS Flex with built-in zone distribution.

These modules use normalized, table-style map variables to describe infrastructure across regions, subscriptions, and workloads. Each map functions like a relational database, linking networks, VM sets, resource groups, key vaults, and more through consistent, composable inputs.

All lower layers are generic and reusable. Solution-specific modules, such as the Epic layer, build on top of this foundation. The Epic module will remain private; others may be public or private depending on scenario.

This modular approach supports:

- **Reusability** – Modules are composable and useful on their own.
- **Maintainability** – Focused layers reduce complexity and risk.
- **Shareability** – Only the Epic-specific layer is private; the rest can be reused or published.

![Module stack](assets/avmstack.png)

## Infrastructure Map Model

This section introduces the normalized infrastructure map that underpins the module stack. It defines Azure infrastructure using a relational-style model—expressed through Terraform map variables—that cleanly connects networks, VM sets, resource groups, and other resources. Epic-specific modules build on this foundation by layering in a domain-specific map of the resources required for a complete Epic environment.

```mermaid
---
title: Infrastructure Map Model
---
erDiagram
  Locations ||--o{ "Resource Groups" : ""
  Locations ||--o{ "Networks" : ""
  Locations ||--o{ "Role-Based VM Sets" : ""
  Locations ||--o{ "Key Vaults" : ""
  Locations ||--o{ "Storage Accounts" : ""
  Subscriptions ||--o{ "Key Vaults" : ""
  Subscriptions ||--o{ "Resource Groups" : ""
  Subscriptions ||--o{ "Networks" : ""
  Subscriptions ||--o{ "Role-Based VM Sets" : ""
  Subscriptions ||--o{ "Storage Accounts" : ""
  "Resource Groups" ||--o{ "Role-Based VM Sets" : ""
  "Resource Groups" ||--o{ "Key Vaults" : ""
  "Resource Groups" ||--o{ "Storage Accounts" : ""
  "Subscriptions" ||..|| "Resource Groups" : "has a default"
  "Subscriptions" ||..|| "Resource Groups" : "has a dedicated private link"
  "Subscriptions" ||--o{ "Networks" : ""
  "Subscriptions" ||--o{ "Role-Based VM Sets" : ""
  "Subscriptions" ||--o{ "Key Vaults" : ""
  "VM Extensions" }o--o{ "Role-Based VM Sets" : ""
  "Networks" ||..o{ "Subnets" : ""
  "External Networks" ||..o{ "External Subnets" : ""
  "Subnets" ||..o{ "Routes" : ""
  "Routes" ||--|| "Networks" : "to"
  "Routes" ||--|| "External Networks" : "to"
  "Routes" ||--|| "Subnets" : "to"
  "Routes" ||--|| "External Subnets" : "to"
  "Subnets" ||..o{ "Security Rules" : "protect"
  "Security Rules" ||--o{ "Networks" : "to/from"
  "Security Rules" ||--o{ "Subnets" : "to/from"
  "Security Rules" ||--o{ "External Networks" : "to/from"
  "Security Rules" ||--o{ "External Subnets" : "to/from"
  "Key Vaults" ||..o{ "Role-Based VM Sets" : "protect"
  "Role-Based VM Sets" ||..|{ "Network Interfaces" : "have"
  "Role-Based VM Sets" ||..|{ "Data Disks" : "have"
  "Subnets" ||--o{ "Network Interfaces" : "contain"
  "Role-Based VM Sets" ||--o| "Availability Zone Distribution Strategy" : "uses"
  "Role-Based VM Sets" ||--|| "VM Set Specs" : "have"
  "VM Set Specs" ||..o{ "Data Disk Specs" : "have"
  "Data Disks" ||..|| "Data Disk Specs" : "have"
  "Resource Groups" ||--o{ "Networks" : "have"
  "Key Vaults" ||--o{ "Private Endpoints" : "have"
  "Subnets" ||--o{ "Private Endpoints" : "have"
  "Storage Accounts" ||--o{ "Private Endpoints" : "have"
  "Networks" ||..o{ "Peerings" : "have"
  "Peerings" ||--|| "Networks" : "peered to"
  "Peerings" ||--|| "External Networks" : "peered to"
```

> In the sections below, the 🔑 icon represents a "foreign key" property that references another table/map variable.

### Locations
> Terraform variable: `var.locations`

The `locations` variable identifies the model's Azure locations.

```hcl
locations = {
  primary = "eastus" // Must be a valid Azure location
  alt     = "westus" // Must be a valid Azure location
}
```

### Subscriptions
> Terraform variable: `var.subscriptions`

The `subscriptions` variable identifies the model's Azure subscriptions.

```hcl
subscriptions = {
  production = {
    default_resource_group_name      = "production"               // 🔑 Must be in var.resource_groups
    private_link_resource_group_name = "production_networks"      // 🔑 Optional; must be in var.resource_groups
    subscription_slot                = "az_subscription_1"        // References a named azurerm provider
  }
  non_production = {
    default_resource_group_name      = "non_production"          
    private_link_resource_group_name = "non_production_networks"
    subscription_slot                = "az_subscription_2"
  }
}
```

* `default_resource_group_name` must refer to a resource group defined in [`var.resource_groups`](#resource-groups).
* When provided, `private_link_resource_group_name` must refer to a resource group defined in [`var.resource_groups`](#resource-groups).
  * If not provided, `default_resource_group_name` will be used.
* `subscription_slot` refers to a static `azurerm` provider alias (`az_subscription_1` - `az_subscription_10`).

### Resource groups
> Terraform variable: `var.resource_groups`

The `resource_groups` variable identifies the model's Azure subscriptions.

```hcl
resource_groups = {
  production = {
    subscription_name = "production"      // 🔑 Must be in var.subscriptions
    location_name     = "primary"         // 🔑 Optional; Must be in var.locations
    name              = "production"      // The actual name of the resource group
  }
  non_production = {
    subscription_name = "non_production"
    location_name     = "alt"
    name              = "non-production"
  }
}
```

* `subscription_name` must refer to a subscription defined in [`var.subscriptions`](#subscriptions).
* When provided, `location_name` must refer to a location defined in [`var.locations`](#locations).
  * If no `location_name` is provided, the default (i.e., first location defined in `var.locations`) will be used.

### Virtual machine extensions
> Terraform variable: `var.virtual_machine_extensions`

The `virtual_machine_extensions` variable identifies the model's virtual machine extension configurations. The example below is used to configure the Azure Monitor Agent for Windows.

```hcl
virtual_machine_extensions = {
  azure_monitor = {
    name                       = "AzureMonitorWindowsAgent"
    publisher                  = "Microsoft.Azure.Monitor"
    type                       = "AzureMonitorWindowsAgent"
    type_handler_version       = "1.2"
    auto_upgrade_minor_version = true
    automatic_upgrade_enabled  = true
    settings                   = null
  }
}
```

### Networks
> Terraform variable: `var.networks`

The `networks` variable identifies the model's networks. Note that this is different than external networks (which may be on-premises, in Azure, or in another cloud) defined in `var.external_networks`.

```hcl
  networks = {
    main = {
      location_name       = "primary"      // 🔑 Must be in var.locations
      subscription_name   = "production"   // 🔑 Must be in var.subscriptions
      resource_group_name = "production"   // 🔑 Must be in var.resource_groups
      name                = "main-vnet"    // Optional; if not provided, will be derived from key "main"
      address_space       = "10.0.0.0/16"

      subnets = {
        subnet_a = {
          name            = "subnet-a"     // Optional; if not provided, will be derived from key "subnet_a"
          address_space   = "10.0.0.0/24"
        }
        subnet_b = {
          name            = "subnet-b"
          address_space   = "10.0.1.0/24"
        }
      }     
    }
  }
```

* `subscription_name` must refer to a subscription defined in [`var.subscriptions`](#subscriptions).
* `location_name` must refer to an Azure location defined in [`var.locations`](#locations).
* `resource_group_name` must refer to a resource group in [`var.resource_groups`](#resource-groups).

#### Peerings

The `peerings` section of the `networks` variable describes each network's peerings. These peerings can refer to other networks and subnets described in this model (via `var.networks`) or external networks and subnets (via `var.external_networks`).

```hcl
networks = {
  main = {
    ...

    subnets = {
      ...
    }

    peered_to = [
      "alt"  // Peer this network to the "alt" network declared below
    ]
  }
  alt = {
    ...

    subnets = {
      ...
    }

    peered_to = [
      "main"  // Peer this network to the "main" network declared above
    ]
  }
}
```

* `peered_to` networks must be defined in either `var.networks` or `var.external_networks`.
* Only `var.external_networks` that have a valid Azure `resource_id` can be peered to.

#### Routes

The `routes` section within `subnets`, as defined by the `networks` variable, specifies custom network routes for each subnet. These routes determine how traffic is directed, whether to a network gateway, the Internet, a virtual network appliance, or simply dropped. The sections below demonstrate how to configure `routes` for each of these scenarios. Traffic destinations can be defined either as fixed address spaces in CIDR format or as references to networks and subnets defined in `var.networks` and `var.external_networks`.

> [!IMPORTANT]
> A dedicated route table is created for each network in which you have `routes` defined. If no `routes` are defined, no route table is created.

##### Example: Route traffic to a network gateway for a fixed address space

```hcl
networks = {
  main = {
    ...

    subnets = {
      route_traffic = {
        destined_for = {
          address_space = "192.168.1.0/24"  // Destined for a fixed address space
        }

        to_gateway = true                   // Route traffic to the gateway
      }
    }
  }
}
```

##### Example: Route traffic to the Internet for a network defined in `var.networks` 

```hcl
networks = {
  main = {
    ...

    subnets = {
      route_traffic = {
        destined_for = {
          network_name = "alt"  // Destined for the "alt" network defined below
        }

        to_internet = true      // Route traffic to the Internet
      }
    }
  }

  alt = {                     
    ...
  }
}
```

##### Example: Route traffic to an appliance for a subnet defined in `var.networks`

```hcl
networks = {
  main = {
    ...

    subnets = {
      route_traffic = {
        destined_for = {
          network_name = "alt"        // Route traffic destined for subnet "subnet_b" in
          subnet_name  = "subnet_b"   // network "alt" defined below
        }

        to_appliance = {
          ip_address = "192.168.1.1"  // To an appliance at 192.168.1.1
        }
      }
    }
  }

  alt = {
    ...

    subnets = {
      subnet_b = {
        ...
      }
    }
  }
}
```

##### Example: Drop all traffic destined for the Internet

```hcl
networks = {
  main = {
    ...

    subnets = {
      route_traffic = {
        destined_for = {
          address_space = "0.0.0.0/0"  // Route traffic destined for the Internet
        }

        to_nowhere = true              // to nowhere
      }
    }
  }
}
```

#### Security rules

Each subnet in a virtual network defined in `var.networks` can include layer 4 security rules, which are translated into network security group (NSG) rules in Azure during deployment. This approach uses a straightforward, fluent syntax to define security rules, as illustrated below. These rules allow you to manage:

* Source and destination address ranges
* Source and destination port ranges
* Rule priorities (translated to NSG priorities)

The fluent syntax supports defining address ranges by referencing internal networks and subnets (`var.networks`) as well as external networks and subnets (`var.external_networks`).

> [!IMPORTANT]
> A dedicated network security group is created for each network regardless of whether or not you have `security_rules` configured.

##### Example: Allow traffic in from a static address space

```hcl
networks = {
  main = {
    ...

    subnets = {
      subnet_a = {
        security_rules = {
          priority = "100"                    // Rule priority is 100
          allow = { in = { from = {           // Allow in from...
            address_space = "192.168.1.0/24"  // Address space "192.168.1.0/24"
            port_range    = "443"             // On port 443
          }}}
        }
      }
    }
  }
}
```

##### Example: Allow all traffic in from a network defined in `var.subnets`

```hcl
networks = {
  main = {
    ...

    subnets = {
      subnet_a = {
        security_rules = {
          priority = "110"             // Rule priority is 110
          allow = { in = { from = {    // Allow in from...
            network = {    
              network_name = "alt"     // "alt" network
              port_range   = "100-200" // On any port between 100-200
            }
          }}}
        }
      }
    }
  }

  alt = {
    ...
  }
}
```

##### Example: Deny all inbound traffic from a subnet defined in `var.networks`

```hcl
networks = {
  main = {
    ...

    subnets = {
      subnet_a = {
        security_rules = {
          priority = "120"              // Rule priority is 120
          deny = { in = { from = {      // Deny in from...
            subnet = {    
              network_name = "alt"      // "alt" network
              subnet_name  = "subnet_b" // "subnet_b" subnet
              port_range   = "443"      // On port 443
            }
          }}}
        }
      }
    }
  }

  alt = {
    ...

    subnets = {
      subnet_b = {
        ...
      }
    }
  }
}
```

##### Example: Allow all outbound traffic to a static address space 

```hcl
networks = {
  main = {
    ...

    subnets = {
      subnet_a = {
        security_rules = {
          priority = "130"                    // Rule priority is 130
          allow = { out = { to = {            // Allow out to...
            address_space = "192.168.1.0/24"  // Address space "192.168.1.0/24"
            port_range    = "443"             // On port 443
          }}}
        }
      }
    }
  }
}
```

##### Example: Deny all outbound traffic to a network defined in `var.networks`

```hcl
networks = {
  main = {
    ...

    subnets = {
      subnet_a = {
        security_rules = {
          priority = "140"          // Rule priority is 140
          deny = { out = { to = {   // Deny out to...
            network = {
              network_name = "alt"  // "alt" network
            }

            port_range    = "443"   // On port 443
          }}}
        }
      }
    }
  }

  alt = {
    ...
  }
}
```

##### Example: Allow all outbound traffic to a subnet defined in `var.networks`

```hcl
networks = {
  main = {
    ...

    subnets = {
      subnet_a = {
        security_rules = {
          priority = "150"               // Rule priority is 150
          allow = { out = { to = {       // Allow out to...
            subnet = {
              network_name = "alt"       // "alt" network
              subnet_name  = "subnet_b"  // "subnet_b" subnet
            }

            port_range    = "443"        // On port 443
          }}}
        }
      }
    }
  }

  alt = {
    ...

    subnets = {
      subnet_b = {
        ...
      }
    }
  }
}
```

### Role-based virtual machine set

This module is designed to deploy highly available sets of virtual machines (VMs) that share a common role, workload, and availability characteristics after networks have been deployed. By default, VMs are evenly distributed across availability zones, but this behavior can be customized using var.virtual_machine_set_zone_distribution. The specifications for VM sets, including VM count, SKU, and disk configurations, are defined in a separate table/map variable: var.virtual_machine_set_specs. There is a 1-to-1 relationship between var.virtual_machine_sets, var.virtual_machine_set_specs, and var.virtual_machine_set_zone_distribution. These variables are separated to streamline automation, as the information often originates from different sources.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
