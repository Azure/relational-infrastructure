# Azure Relational Infrastructure (AzRI)

> [!IMPORTANT]
> Azure Relational Infrastructure is currently in preview.

## Overview

The AzRI [Terraform module](https://developer.hashicorp.com/terraform/language/modules) stack simplifies [Azure infrastructure](https://azure.microsoft.com/resources/cloud-computing-dictionary/what-is-iaas) deployment with a simple relational model that cuts code complexity by up to 70%¹. Built on Microsoft’s [Azure Verified Modules (AVM)](https://aka.ms/avm) and aligned closely with [Azure's Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/), AzRI's modular design uses [.tfvars files](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files) to streamline IaC for a wide range of Azure infrastructure-based environments. The model, visualized as an entity relationship diagram (ERD) below, arranges resources—Locations, Subscriptions, Role-Based VM Sets, Networks, Key Vaults—as [Terraform maps](https://developer.hashicorp.com/terraform/language/expressions/types#maps-objects), like database tables with primary keys (map keys) and foreign keys (e.g., `location_name`), enabling rapid, resilient, and simple deployments.

> ¹ Estimated 70% code reduction based on conventional multi-resource setup comparisons ([HashiCorp, 2023](https://www.hashicorp.com/state-of-the-cloud)).

## Model Reference

This section defines the core of AzRI: a normalized infrastructure map that organizes Azure resources like a relational database. Using Terraform map variables, it creates a structured model where resources—such as [Locations](#locations), [Subscriptions](#subscriptions), [Role-Based VM Sets](#virtual-machine-sets), [Networks](#networks), [Key Vaults](#key-vaults), and [Storage Accounts](#storage-accounts)—are linked through primary keys (map keys) and foreign keys (e.g., `subscription_name`). This blueprint ensures flexibility and scalability, supporting Epic on Azure deployments or custom Azure projects with a reusable foundation. [Epic-specific configurations are applied via private `.tfvars` files](/epic/), maintaining security and compliance.

An entity-relationship diagram (ERD) in the infrastructure model documentation visualizes these connections, detailing cardinality (e.g., one [Subscription](#subscriptions) to many [Resource Groups](#resource-groups)) and dependencies. It shows how resources like [VMSS Flex-based Role-Based VM Sets](#virtual-machine-sets), configured with [`maintenance_schedules`](#maintenance-schedules) for high availability, integrate with [Networks](#networks) and [Key Vaults](#key-vaults), driving ARI’s ability to manage complex, [multi-subscription](#subscriptions) environments.

```mermaid
---
title: Infrastructure Map Model
config:
        layout: elk
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
  "Lock Groups" ||--o{ "Resource Groups" : "lock"
  "Lock Groups" ||--o{ "Networks" : "lock"
  "Lock Groups" ||--o{ "Key Vaults" : "lock"
  "Lock Groups" ||--o{ "Role-Based VM Sets" : "lock"
  "Lock Groups" ||--o{ "Data Disks" : "lock"
  "Lock Groups" ||--o{ "Network Interfaces" : "lock"
  "Lock Groups" ||--o{ "Private Endpoints" : "lock"
  "Lock Groups" ||--o{ "Storage Accounts" : "lock"
  "Storage Accounts" ||--o{ "Blob Containers" : "have"
  "Storage Accounts" ||--o{ "File Shares" : "have"
```

> [!NOTE]
> In the sections below:
> * 🔑 indicates a "primary key"; typically the "one" side of a one-to-many relationship
> * 🔗 indicates a "foreign key"; typically the "many" side of a one-to-many relationship

### Locations

> Terraform variable: `var.locations`

The `locations` table defines the Azure regions where your infrastructure lives, like `eastus` or `westus`. It’s the starting point for placing resources geographically, ensuring they align with [Azure’s global regions](https://learn.microsoft.com/azure/reliability/regions-list) for availability and compliance. In the entity-relationship diagram (ERD), `locations` acts as a reference point, linking one-to-many with tables like networks or virtual machine sets to specify where they’re deployed.

```hcl
locations = {
  primary = "eastus"  # 🔑 "primary" location; must be a valid Azure region (see below)
  alt     = "westus"  # 🔑 "alt" location; must be a valid Azure region (see below)
}
```

> [!TIP]
> **Powershell Users:** For a complete list of valid Azure locations, [install the Az Powershell module](https://learn.microsoft.com/powershell/azure/install-azure-powershell), then run the following command:
> ```powershell
> Get-AzLocation | Select-Object -Property Name | ForEach-Object { $_.Name }
> ```

> [!TIP]
> **Azure CLI/Bash Users:** For a complete list of valid Azure locations, [install the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli), then run the following command:
> ```bash
> az account list-locations --query "[].name" -o tsv
> ```

### Subscriptions

> Terraform variable: `var.subscriptions`

> [!IMPORTANT]
> Up to ten (10) subscriptions are supported.

The `subscriptions` table organizes your [Azure subscriptions](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-setup-guide/organize-resources#management-levels-and-hierarchy), acting as a control center for grouping resources across your environment. Each subscription connects to [resource groups](#resource-groups) and Terraform providers, setting the scope for your infrastructure. In the entity-relationship diagram (ERD), `subscriptions` serves as a central hub, with one-to-many links to tables like [`resource_groups`](#resource-groups) and [`networks`](#networks), ensuring resources stay aligned.

```hcl
subscriptions = { 
  production = {                                                  # 🔑 "production" subscription
    default_resource_group_name      = "production"               # 🔗 Links to var.resource_groups
    private_link_resource_group_name = "production_networks"      # 🔗 Optional; links to var.resource_groups
    subscription_id                  = "00000000-0000..."         # Azure subscription ID (must be a GUID)
  }
  non_production = {                                              # 🔑 "non_production" subscription
    default_resource_group_name      = "non_production"           # 🔗 Links to var.resource_groups    
    private_link_resource_group_name = "non_production_networks"  # 🔗 Optional; Links to var.resource_groups
    subscription_id                  = "10000000-0000..."         # Azure subscription ID (must be a GUID)
  }
}
```

| Field | Description |
|-------|-------------|
| `default_resource_group_name` | Links to a key in [`var.resource_groups`](#resource-groups). Defines the primary resource group for the subscription. |
| `private_link_resource_group_name` | Optional; if set, links to a key in [`var.resource_groups`](#resource-groups) for private link resources. Defaults to `default_resource_group_name` if unset. |
| `subscription_id` | References a specific Azure subscription ID. Must be a GUID. |

### Lock Groups

> Terraform variable: `var.lock_groups`

The `lock_groups` table groups Azure resources—like [VMs](#virtual-machine-sets), [networks](#networks), or [disks](#virtual-machine-data-disks)—into logical sets for coordinated [lock management](https://learn.microsoft.com/azure/azure-resource-manager/management/lock-resources) during maintenance, such as updating a region’s infrastructure or a compute tier. Resources in tables like [`var.virtual_machine_sets`](#virtual-machine-sets) or [`var.networks`](#networks) can list lock group keys in their `lock_groups` property to join one or more groups. Each group toggles locks (CanNotDelete or ReadOnly) for its members. If a resource belongs to multiple groups with `locked = true`, the most restrictive lock applies: ReadOnly (no changes) overrides CanNotDelete (allows updates). In the ERD, `lock_groups` has a many-to-many relationship with resources, linked via `lock_groups` properties in other tables.

```hcl
lock_groups = {
  production_lock = {      # 🔑 Primary key: "production_lock"
    locked    = true       # Locks enabled
    read_only = true       # ReadOnly lock
  }
  non_production_lock = {  # 🔑 Primary key: "maintenance_lock"
    locked    = false      # Locks disabled
    read_only = false      # CanNotDelete lock
  }
}
```

> [!IMPORTANT]  
> When a resource belongs to multiple locked groups (via its `lock_groups` property), the most restrictive lock wins: a ReadOnly lock (`read_only = true`) takes precedence over a CanNotDelete lock (`read_only = false`).

| Field | Description |
|-------|-------------|
| `locked` | Required; if `true`, applies locks to group resources; if `false`, removes them for maintenance. |
| `read_only` | Optional; if `true`, applies ReadOnly locks (no changes); if `false`, applies CanNotDelete locks (allows updates). Defaults to `false`. ReadOnly wins if multiple locked groups apply. |

### Resource Groups

> Terraform variable: `var.resource_groups`

The `resource_groups` table defines the [Azure resource groups](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-setup-guide/organize-resources#management-levels-and-hierarchy) that bundle related resources together in your environment. Each resource group ties to a subscription and, optionally, a location, organizing assets like networks or VMs. In the entity-relationship diagram (ERD), `resource_groups` links one-to-one with `subscriptions` and optionally to `locations`, acting as a container for other resources.

```hcl
resource_groups = {
  production = {                         # 🔑 "production" resource group
    subscription_name = "production"     # 🔗 Links to var.subscriptions
    location_name     = "primary"        # 🔗 Optional; links to var.locations
    name              = "production"     # Resource group name in Azure

    lock_groups = [
      "production_lock"                  # 🔗 Optional; links to var.lock_groups
    ]
  }
  non_production = {                     # 🔑 "non_production" resource group
    subscription_name = "non_production" # 🔗 Links to var.subscriptions
    location_name     = "alt"            # 🔗 Optional; links to var.locations
    name              = "non-production" # Resource group name in Azure

    lock_groups = [
      "non_production_lock"              # 🔗 Optional; links to var.lock_groups
    ]
  }
}
```

| Field | Description |
|-------|-------------|
| `subscription_name` | Links to a key in [`var.subscriptions`](#subscriptions). Defines the subscription this resource group belongs to. |
| `location_name` | Optional; if set, links to a key in [`var.locations`](#locations). Specifies the Azure region for the resource group. Defaults to the first location in `var.locations` if unset. |
| `lock_groups` | Optional; if set, links to keys in [`var.lock_groups`](#lock-groups). Specifies the resource lock groups that this resource group belongs to. |
| `name` | The name of the resource group as it appears in Azure, used to identify it. |

### Maintenance Schedules

> Terraform variable: `var.maintenance_schedules`

[The `maintenance_schedules` table defines when Azure applies platform updates](https://learn.microsoft.com/azure/virtual-machines/maintenance-configurations), like patches or upgrades, to your [virtual machines](#virtual-machine-sets). Each schedule specifies a start time, update period, and how often updates repeat (daily, weekly, or monthly). In the ERD, `maintenance_schedules` links one-to-one with [`subscriptions`](#subscriptions) and one-to-many with [`virtual_machine_sets`](#virtual-machine-sets), aligning update plans with your infrastructure.

```hcl
maintenance_schedules = {
  guest_updates = {                                # 🔑 Primary key: "guest_updates"
    repeat_every = {                               # Updates every...
      week = true                                  # week
    }
    start_date_time_utc = "2025-01-05 22:00"       # Window starts at 22:00
    duration            = "2:00"                   # Updates take 2 hours
  }
  host_updates = {                                 # 🔑 Primary key: "host_updates"
    repeat_every = {                               # Updates every...
      days = 7                                     # 7 days
    }
    start_date_time_utc      = "2025-01-06 23:00"  # Window starts at 23:00
    expiration_date_time_utc = "2026-01-06 23:00"  # Expires after 1 year
    duration                 = "1:30"              # Updates take 90 minutes
  }
}
```

> [!IMPORTANT]  
> [VMs](#virtual-machine-sets) must be running 15 minutes before the update start time. Schedule updates during low-traffic periods to avoid impact.

| Field | Description |
|-------|-------------|
| `repeat_every` | Required; sets the update frequency: `day` (daily), `week` (weekly), `month` (monthly), `days` (every n days), `weeks` (every n weeks), or `months` (every n months). Only one option can be set. |
| `start_date_time_utc` | Required; specifies the first update time in UTC, e.g., `2025-01-05 22:00`. |
| `expiration_date_time_utc` | Optional; sets when the schedule ends, e.g., `2026-01-06 23:00`. Defaults to `null` (no expiration). |
| `duration` | Optional; defines the update period in HH:MM format, e.g., `2:00` or `1:30`. Defaults to `1:30` (90 minutes). Minimum varies by scope (e.g., 1.5h for guest updates). |

### Virtual Machine Extensions

> Terraform variable: `var.virtual_machine_extensions`

The `virtual_machine_extensions` table sets up extensions for [Azure VMs](#virtual-machine-sets), adding capabilities like monitoring or management tools. It defines settings such as publisher, type, and versioning for consistent application across your environment. In the ERD, `virtual_machine_extensions` links one-to-many to [`virtual_machine_sets`](#virtual-machine-sets), letting multiple VM sets share the same extension config—like the [Azure Monitor Agent](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview) for Windows shown below.

```hcl
virtual_machine_extensions = {
  azure_monitor = {  // 🔑 "azure_monitor" extension
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

| Field | Description |
|-------|-------------|
| `name` | Identifies the extension within the VM, e.g., `AzureMonitorWindowsAgent`. |
| `publisher` | Specifies the extension’s provider, like `Microsoft.Azure.Monitor`. |
| `type` | Defines the extension type, such as `AzureMonitorWindowsAgent`. |
| `type_handler_version` | Sets the extension handler version, e.g., `1.2`. |
| `auto_upgrade_minor_version` | Enables automatic minor version updates if `true`. |
| `automatic_upgrade_enabled` | Activates automatic upgrades for the extension if `true`. |
| `settings` | Optional; holds custom settings for the extension, or `null` if unused. |

### Networks

> Terraform variable: `var.networks`

The `networks` table defines the virtual networks (VNets) in your Azure environment, distinct from external networks (e.g., on-premises or other clouds) covered in `var.external_networks`. It organizes VNets and their subnets, linking them to [subscriptions](#subscriptions), [locations](#locations), and [resource groups](#resource-groups). In the ERD, `networks` connects one-to-many with `subnets` and one-to-one with [`subscriptions`](#subscriptions), [`locations`](#locations), and [`resource_groups`](#resource-groups), anchoring your network topology.

```hcl
networks = {
  main = {                               # 🔑 "main" network
    location_name       = "primary"      # 🔗 Links to var.locations
    subscription_name   = "production"   # 🔗 Links to var.subscriptions
    resource_group_name = "production"   # 🔗 Links to var.resource_groups
    name                = "main-vnet"    # Optional; defaults to key 🔑 "main" if unset
    address_space       = "10.0.0.0/16"  # Defines network address space in CIDR format

    lock_groups = [
      "production_lock"                  # 🔗 Optional; links to var.lock_groups
    ]

    subnets = {
      subnet_a = {                       # 🔑 "subnet_a" subnet
        name            = "subnet-a"     # Optional; defaults to key 🔑 "subnet_a" if unset
        address_space   = "10.0.0.0/24"  # Defines "subnet_a" address space in CIDR format
      }

      subnet_b = {                       # 🔑 "subnet_b" subnet
        name            = "subnet-b"     # Optional, defaults to key 🔑 "subnet_b" if unset
        address_space   = "10.0.1.0/24"  # Defines "subnet_a" address space in CIDR format
      }
    }
  }
}
```

| Field | Description |
|-------|-------------|
| `location_name` | Links to a key in [`var.locations`](#locations), specifying the Azure region for the VNet. |
| `subscription_name` | Links to a key in [`var.subscriptions`](#subscriptions), tying the VNet to a subscription. |
| `resource_group_name` | Links to a key in [`var.resource_groups`](#resource-groups), defining the resource group for the VNet. |
| `lock_groups` | Optional; if set, links to keys in [`var.lock_groups`](#lock-groups). Specifies the resource lock groups that this VNet belongs to. |
| `name` | Optional; names the VNet in Azure, defaults to the map key (e.g., `main`) if not set. |
| `address_space` | Defines the VNet’s IP address range, e.g., `10.0.0.0/16`. |
| `subnets` | A nested map of subnets, each with a `name` (optional, defaults to key) and `address_space` for its IP range. |

#### Peerings

> Terraform variable: `var.networks.peered_to`

The `peerings` section within the [`networks`](#networks) table sets up virtual network peerings, connecting [VNets within this model (`var.networks`)](#networks) or to [external networks (`var.external_networks`)](#external-networks). It enables traffic flow between networks, like linking a primary and alternate VNet. In the ERD, `peerings` represents a many-to-many relationship between [`networks`](#networks), or between [`networks`](#networks) and [`external_networks`](#external-networks), facilitating flexible network topologies.

> [!IMPORTANT]
> Network peerings are a one-way connection. Each `peered_to` entry establishes traffic flow from the source network to the target network only. For two-way communication, you must configure reciprocal peerings in both directions (e.g., `main` to `alt` and `alt` to `main`).

```hcl
networks = {
  main = {         # 🔑 "primary" network
                   # Other fields like location_name, subnets...
    peered_to = [  # Multiple peerings can be declared
      "alt"        # 🔗 Links to var.networks
    ]
  }
  alt = {          # 🔑 "alt" network
                   # Other fields like location_name, subnets...
    peered_to = [  # Multiple peerings can be declared
      "main"       # 🔗 Links to var.networks
    ]
  }
}
```

| Field | Description |
|-------|-------------|
| `peered_to` | A list of network keys from [`var.networks`](#networks) or [`var.external_networks`](#external-networks) to peer with. For `external_networks`, a valid Azure `resource_id` is required. |

#### Routes

> Terraform variable: `var.networks.subnets.route_traffic`

The `route_traffic` section is an optional map within each subnet of the [`networks`](#networks) table, defining custom routing rules for that subnet. Each route directs traffic to gateways, the Internet, appliances, or nowhere (dropped), with destinations as CIDR address spaces, networks, or networks and subnets declared in [`var.networks`](#networks) and [`var.external_networks`](#external-networks). In the ERD, `route_traffic` is a one-to-many child of `subnets`, linking to [`networks`](#networks) or `subnets` via `destined_for`. A route table is created per subnet only if `route_traffic` is defined.

```hcl
networks = {
  main = {                                      # 🔑 "main" network
    # Other fields...
    subnets = {
      subnet_a = {                              # 🔑 "subnet_a" subnet
        address_space = "10.0.0.0/24"           # Subnet address space in CIDR format
        route_traffic = {                       # Traffic routing rules
          gateway_route = {                     # 🔑 "gateway_route" route
            destined_for = {                    # When traffic is destined for...
              address_space = "192.168.1.0/24"  # the "192.168.1.0/24" address space...
            }
            to_gateway = true                   # route to the default network gateway
          }
          internet_route = {                    # 🔑 "internet_route" route
            destined_for = {                    # When traffic is destined for...
              network = {                       # Network defined in var.networks or var.external_networks...
                network_name = "alt"            # 🔗 linked to "alt" network in var.networks
              }
            }
            to_internet = true                  # route to the Internet
          }
          appliance_route = {                   # 🔑 "appliance_route" route
            destined_for = {                    # When traffic is destined for...
              subnet = {                        # Subnet defined in var.networks or var.external_networks...
                network_name = "alt"            # 🔗 linked to "alt" network in var.networks
                subnet_name  = "subnet_b"       # 🔗 linked to "subnet_b" subnet in var.networks.subnets
              }
            }
            to_appliance = {                    # route to a virtual appliance...
              ip_address = "192.168.1.1"        # running at "192.168.1.1"
            }
          }
          drop_route = {                        # 🔑 "drop_route" route
            destined_for = {                    # When traffic is destined for...
              address_space = "0.0.0.0/0"       # the Internet (0.0.0.0/0)...
            }
            to_nowhere = true                   # drop it
          }
        }
      }
    }
  }
  alt = {                                       # 🔑 "alt" network
    # Other fields...
    subnets = {
      subnet_b = {                              # 🔑 "subnet_b" subnet
        address_space = "10.1.0.0/24"           # Subnet address space in CIDR format
      }
    }
  }
}
```

> [!IMPORTANT]  
> A dedicated route table is created for each subnet with `route_traffic` defined. If no routes are specified, no route table is created.

| Field | Description |
|-------|-------------|
| `destined_for` | Required; sets the traffic target: `address_space` (CIDR, e.g., `192.168.1.0/24`), `network` (links to [`var.networks`](#networks) via `network_name`), or `subnet` (links to [`var.networks`](#networks) via `network_name` and `subnet_name`). |
| `route_name` | Optional; names the route, defaults to `null` (auto-generated). |
| `to_gateway` | Optional; if `true`, routes to a network gateway. Defaults to `false`. |
| `to_internet` | Optional; if `true`, routes to the Internet. Defaults to `false`. |
| `to_nowhere` | Optional; if `true`, drops traffic. Defaults to `false`. |
| `to_appliance` | Optional; routes to an appliance with `ip_address` (e.g., `192.168.1.1`). Defaults to `null`. |

#### Security Rules

> Terraform variable: `var.networks.subnets.security_rules`

The `security_rules` section within `subnets` of the [`networks`](#networks) table configures [layer 4 network security group (NSG)](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview) rules for each subnet, controlling inbound and outbound traffic. Using a fluent syntax, rules define source/destination addresses, ports, and priorities, referencing [`var.networks`](#networks) or [`var.external_networks`](#external-networks). In the ERD, `security_rules` is a child of `subnets`, with one-to-many links to traffic rules. An NSG is created for each network, regardless of whether `security_rules` is defined.

```hcl
networks = {
  main = {                                      # 🔑 "main" network
                                                # Other fields like location_name...
    subnets = {                        
      subnet_a = {                              # 🔑 "subnet_a" subnet
        security_rules = {                      # Layer 4 (NSG) security rules
          allow_static_in = {                   # 🔑 "allow_static_in" rule
            priority = "100"                    # Rule priority is 100
            allow = { in = { from = {           # Allow in from...
              address_space = "192.168.1.0/24"  # any IP in 192.168.1.0/24
              port_range    = "443"             # on port 443
            }}}
          },
          allow_network_in = {                  # 🔑 "allow_network_in" rule
            priority = "110"                    # Rule priority is 110
            allow = { in = { from = {           # Allow in from...
              network = {                       # network defined in var.networks or var.external_networks
                network_name = "alt"            # 🔗 linked to "alt" network in var.networks
                port_range   = "100-200"        # on ports 100-200
              }
            }}}
          },
          deny_subnet_in = {                    # 🔑 "deny_subnet_in" rule
            priority = "120"                    # Rule priority is 120
            deny = { in = { from = {            # Deny in from...
              subnet = {                        # subnet defined in var.networks or var.external_networks
                network_name = "alt"            # 🔗 linked to "alt" network in var.networks
                subnet_name  = "subnet_b"       # 🔗 linked to "subnet_b" subnet in var.networks.subnets
                port_range   = "443"            # on port 443
              }
            }}}
          },
          allow_static_out = {                  # 🔑 "allow_static_out" rule
            priority = "130"                    # Rule priority is 130
            allow = { out = { to = {            # Allow out to...
              address_space = "192.168.1.0/24"  # any IP in 192.168.1.0/24
              port_range    = "443"             # on port 443
            }}}
          },
          deny_network_out = {                  # 🔑 "deny_network_out" rule
            priority = "140"                    # Rule priority is 140
            deny = { out = { to = {             # Deny out to...
              network = {                       # network defined in var.networks or var.external_networks
                network_name = "alt"            # 🔗 linked to "alt" network in var.networks
                port_range   = "443"            # on port 443
              }
            }}}
          },
          allow_subnet_out = {                  # 🔑 "allow_subnet_out" rule
            priority = "150"                    # Rule priority is 150
            allow = { out = { to = {            # Allow out to...
              subnet = {                        # subnet defined in var.networks or var.external_networks
                network_name = "alt"            # 🔗 linked to "alt" network in var.networks
                subnet_name  = "subnet_b"       # 🔗 linked to "subnet_b" subnet in var.networks.subnets
                port_range   = "443"            # on port 443
              }
            }}}
          }
        }
      }
    }
  }
  alt = {                                       # 🔑 "alt" network
                                                # Other fields...
    subnets = {
      subnet_b = {                              # 🔑 "subnet_b" subnet
                                                # Subnet details...          
      }
    }
  }
}
```

| Field | Description |
|-------|-------------|
| `priority` | Sets the NSG rule priority, e.g., `100`. Lower numbers take precedence. |
| `allow`/`deny` | Defines whether the rule allows or denies traffic, with `in` or `out` specifying direction. |
| `from`/`to` | For `in`, `from` sets the source; for `out`, `to` sets the destination. Can use `address_space` (CIDR), `network` (with `network_name`), or `subnet` (with `network_name` and `subnet_name`) from [`var.networks`](#networks) or [`var.external_networks`](#external-networks). |
| `port_range` | Specifies the port or range (e.g., `443`, `100-200`) for the rule. |

### External Networks

> Terraform variable: `var.external_networks`

The `external_networks` table captures networks outside this model, unlike those defined in [`var.networks`](#networks). These can be on-premises, in Azure, or in another cloud, allowing your infrastructure to interact with them via [routing](#routes), [security rules](#security-rules), or [peering](#peerings). By specifying their address spaces and subnets, you can reference them in [`var.networks`](#networks) configurations. For Azure-based external networks, including a `resource_id` enables one-way [peering](#peerings) from [`var.networks`](#networks), provided you have sufficient permissions. In the ERD, `external_networks` links many-to-many with [`networks`](#networks) through [`peered_to`](#peerings), [`route_traffic`](#routes), and [`security_rules`](#security-rules), with `subnets` as a one-to-many child.

```hcl
external_networks = {                                  
  on_prem_network = {                                 # 🔑 "on_prem_network" external network
    address_space = "10.10.0.0/16"                    # External network address space can be used for
                                                      # configuring routes and security rules
    subnets = {
      on_prem_database = {                            # 🔑 "on_prem_database" external subnet
        name          = "DatabaseSubnet"              
        address_space = "10.10.0.0/24"                # External subnet address space can be used for
      }                                               # configuring routes and security rules
    }
  }

  external_azure_network = {                          # 🔑 "external_azure_network" external network
    address_space = "10.20.0.0/16"                    # External network address space can be used for
                                                      # configuring routes and security rules
    resource_id   = "/subscriptions/12345678..."      # External Azure network resource ID enables seamless
                                                      # var.networks to var.external_networks peering                                               
    subnets = {
      external_service = {                            # 🔑 "external_service" subnet                
        name          = "ServiceSubnet"
        address_space = "10.20.0.0/24"                # External subnet address space can be used for
      }                                               # configuring routes and security rules
    }
  }
}
```

| Field | Description |
|-------|-------------|
| `address_space` | Required; defines the external network’s IP range, e.g., `10.10.0.0/16`, used in routes and security rules. |
| `resource_id` | Optional; Azure resource ID for peering from [`var.networks`](#networks), e.g., `/subscriptions/12345678...`. Requires permissions. Defaults to `null`. |
| `subnets` | Optional; maps subnets with `name` (e.g., `DatabaseSubnet`) and `address_space` (e.g., `10.10.0.0/24`) for detailed routing and security configs. Defaults to `{}`. |

### Virtual Machine Sets

> Terraform variable: `var.virtual_machine_sets`

The `virtual_machine_sets` table configures groups of highly available VMs that share the same role, workload, and availability settings. By default, VMs are spread evenly across [Azure availability zones](https://learn.microsoft.com/azure/reliability/availability-zones-overview?tabs=azure-cli), with [custom distribution possible via `var.virtual_machine_set_zone_distribution`](#virtual-machine-set-zone-distribution). Related specs like VM count, SKU, and disks are defined in [`var.virtual_machine_set_specs`](#virtual-machine-set-specs), maintaining a 1:1 link with `virtual_machine_sets` and [`virtual_machine_set_zone_distribution`](#virtual-machine-set-zone-distribution) to streamline automation. In the ERD, `virtual_machine_sets` connects one-to-one with [`subscriptions`](#subscriptions), [`resource_groups`](#resource-groups), [`locations`](#locations), and [`key_vaults`](#key-vaults), and one-to-many with nested `extensions` and `data_disks`.

```hcl
virtual_machine_sets = {
  database = {                                         # 🔑 "database" VM set                                        
    key_vault_name                    = "primary"      # 🔗 Links to var.key_vaults
    location_name                     = "primary"      # 🔗 Links to var.locations
    resource_group_name               = "production"   # 🔗 Links to var.resource_groups
    subscription_name                 = "production"   # 🔗 Links to var.subscriptions
    name                              = "db"           # Prefix for all VMs in this set
    include_deployment_prefix_in_name = true           # Apply var.deployment_prefix? Default: false

    tags = {
      role = "database"                                # Optional; tags all VMs
    }

    extensions = [                                     # Optional
      "azure_monitor"                                  # 🔗 Links to var.virtual_machine_extensions
    ]

    lock_groups = [                                    # Optional
      "production_lock"                                # 🔗 Links to var.lock_groups
    ]

    maintenance = {                                    # Optional
      schedule_name = "guest_updates"                  # 🔗 Optional; links to var.maintenance_schedules
    }

    os_type                 = "Windows"                # Windows or Linux
    disk_controller_type    = "nvme"                   # Optional; SCSI or NVMe based on SKU
    enable_boot_diagnostics = true                     # Enable boot diagnostics? Default: false
  }
}
```

| Field | Description |
|-------|-------------|
| `key_vault_name` | Links to a key in [`var.key_vaults`](#key-vaults), specifying the key vault for the VM set. |
| `location_name` | Links to a key in [`var.locations`](#locations), setting the Azure region for the VMs. |
| `resource_group_name` | Links to a key in [`var.resource_groups`](#resource-groups), defining the resource group for the VMs. |
| `subscription_name` | Links to a key in [`var.subscriptions`](#subscriptions), tying the VMs to a subscription. |
| `lock_groups` | Optional; if set, links to keys in [`var.lock_groups`](#lock-groups). Specifies the resource lock groups that this VM set belongs to. By default, all child resources including disks and network interfaces inherit these lock groups. |
| `maintenance.schedule_name` | Optional; if set, links to keys in [`var.maintenance_schedules`](#maintenance-schedules). Specifies the maintenance schedule that should be used when applying guest updates for the VMs. |
| `name` | Prefixes all VMs in the set, used in their Azure names. |
| `include_deployment_prefix_in_name` | If `true`, prepends `var.deployment_prefix` to resource names. Default: `false`. |
| `tags` | Optional; applies key-value tags to all VMs, e.g., `role: database`. |
| `extensions` | Optional; lists extensions from [`var.virtual_machine_extensions`](#virtual-machine-extensions) to apply. |
| `os_type` | Specifies the OS: `Windows` or `Linux`. |
| `disk_controller_type` | Optional; sets disk controller to `SCSI` or `NVMe` based on VM SKU. |
| `enable_boot_diagnostics` | If `true`, enables boot diagnostics. Default: `false`. |

> [!TIP]
> Lock groups can be overridden on VM set child resources. See [data disks](#virtual-machine-data-disks) and [network interfaces](#virtual-machine-network-interfaces) for more information.

#### Virtual Machine Image

> Terraform variable: `var.virtual_machine_sets.image`

The `image` section within [`virtual_machine_sets`](#virtual-machine-sets) selects the OS image for VMs, ensuring consistency and compliance. It can reference a custom/shared image by ID or an Azure Marketplace image by details like offer and publisher. In the ERD, `image` is a child of [`virtual_machine_sets`](#virtual-machine-sets), with a one-to-one relationship.

```hcl
virtual_machine_sets = {
  database = {                        # 🔑 "database" VM set
                                      # Other fields...
    image = {
      reference = {
        offer     = "UbuntuServer"    # Image offer name
        publisher = "Canonical"       # Image publisher
        sku       = "18.04-LTS"       # Image edition
        version   = "latest"          # Image version
      }
    }
  }
}

# Or, for a custom image:
# image = {
#   id = "/subscriptions/12345678..."  # Resource ID of custom/shared image
# }
```

| Field | Description |
|-------|-------------|
| `id` | Optional; resource ID for a custom or shared image, e.g., `/subscriptions/12345678...`. |
| `reference` | Optional; defines a Marketplace image with `offer`, `publisher`, `sku`, and `version`. |

#### Virtual Machine Data Disks

> Terraform variable: `var.virtual_machine_sets.data_disks`

The `data_disks` section within [`virtual_machine_sets`](#virtual-machine-sets) configures optional data disks for VMs, specifying their attachment and content source. Each disk defines a logical unit number (LUN), caching mode, and an optional image source, [such as a snapshot](https://learn.microsoft.com/azure/backup/restore-managed-disks), [VHD file](https://learn.microsoft.com/azure/virtual-machines/windows/disks-upload-vhd-to-managed-disk-powershell), [Marketplace image](https://learn.microsoft.com/azure/virtual-machines/managed-disks-overview#convert-an-existing-managed-disk-to-a-new-managed-disk), restored disk from [Azure Backup](https://learn.microsoft.com/azure/backup/restore-managed-disks) or [Azure Site Recovery](https://learn.microsoft.com/en-us/azure/site-recovery/azure-to-azure-tutorial-failover-failback), or empty disk. In the ERD, `data_disks` is a one-to-many child of [`virtual_machine_sets`](#virtual-machine-sets), supporting multiple disks per VM set for versatile storage needs.

```hcl
virtual_machine_sets = {
  database = {                                      # 🔑 "database" VM set
                                                    # Other fields...
    data_disks = {
      copy_disk = {                                 # 🔑 "copy_disk" data disk
        lun                          = 0            # Logical unit number (LUN) is 0
        caching                      = "ReadWrite"  # ReadWrite caching enabled
        enable_public_network_access = false        # Public network access is disabled

        image = {  
          copy = {                                  # Copy an existing managed disk
            resource_id = "/subscriptions/12345678/resourceGroups/rg/providers/Microsoft.Compute/disks/source-disk"
          }
        }

        lock_groups = [                             # Optional; overrides lock groups defined on parent VM set
          "data_disk_lock"                          # 🔗 Links to var.lock_groups
        ]
      }

      import_disk = {                               # 🔑 "import_disk" data disk
        lun = 1                                     # Logical unit number (LUN) is 1

        image = {
          import = {                                # Import a VHD
            uri    = "https://storage.blob.core.windows.net/vhds/sample.vhd"
            secure = true                           # Perform a secure import (recommended)
          }
        }
      }

      platform_disk = {                             # 🔑 "platform_disk" data disk
        lun = 2
                                     # Logical unit number (LUN) is 2
        image = {
          platform = {                              # Copy a platform image (i.e., from the Azure Marketplace)
            image_reference_id = "/subscriptions/12345678/resourceGroups/rg/providers/Microsoft.Compute/images/ubuntu-18.04"
          }
        }
      }

      restore_disk = {                              # 🔑 "restore_disk" data disk
        lun = 3                                     # Logical unit number (LUN) is 3
        image = {
          restore = {                               # Restore the disk from Azure Backup
            resource_id = "/subscriptions/12345678/resourceGroups/rg/providers/Microsoft.Compute/snapshots/backup-snapshot"
          }
        }
      }

      empty_disk = {                                # 🔑 "empty_disk" data disk
        lun = 4                                     # Logical unit number (LUN) is 4
      }                                             # By default, data disk is empty
    }
  }
}
```

| Field | Description |
|-------|-------------|
| `lun` | Required; sets the disk’s logical unit number, e.g., `0`, for attachment order. |
| `caching` | Optional; configures caching: `None`, `ReadOnly`, or `ReadWrite`. Defaults to `ReadWrite`. |
| `enable_public_network_access` | Optional; if `true`, allows public access to the disk for specific use cases. Defaults to `false`. |
| `image` | Optional; specifies the disk’s source: `copy` (from a disk/snapshot), `import` (from a VHD file), `platform` (from a Marketplace image), `restore` (from a backup/snapshot), or `null` (empty disk). |
| `lock_groups` | Optional; if set, links to keys in [`var.lock_groups`](#lock-groups). Specifies the resource lock groups that this data disk belongs to. These lock groups override lock groups defined at the [parent VM set](#virtual-machine-set) level. |

#### Virtual Machine Network Interfaces

> Terraform variable: `var.virtual_machine_sets.network_interfaces`

The `network_interfaces` section within [`virtual_machine_sets`](#virtual-machine-sets) configures the network connectivity for VMs, linking them to specific VNets and subnets. Each interface specifies a network, subnet, and IP settings, with options for accelerated networking. In the ERD, `network_interfaces` is a one-to-many child of [`virtual_machine_sets`](#virtual-machine-sets), with one-to-one links to [`networks`](#networks) and `subnets` via `network_name` and `subnet_name`, ensuring each VM set connects to the right network topology.

> [!IMPORTANT]
> Only one network interface per VM can have [accelerated networking](https://learn.microsoft.com/azure/virtual-network/accelerated-networking-overview?tabs=redhat) enabled (`enable_accelerated_networking = true`). By default, this feature is enabled. If the VM has multiple network interfaces, you must explicitly indicate which network interfaces should not have accelerated networking enabled (`enable_accelerated_networking = false`). 

```hcl
virtual_machine_sets = {
  database = {                                         # 🔑 "database" VM set
                                                       # Other fields...
    network_interfaces = {
      primary_nic = {                                  # 🔑 "primary_nic" network interface
        network_name                  = "main"         # 🔗 Links to var.networks
        subnet_name                   = "subnet_a"     # 🔗 Links to var.networks.main.subnets
        private_ip                    = "10.0.0.10"    # Optional; static IP
        private_ip_allocation         = "Static"       # Optional; static or dynamic
        enable_accelerated_networking = true           # Optional; boost network performance.
                                                       # See __Important__ accelerated networking note above.

        lock_groups = [                                # Optional; overrides lock groups defined on parent VM set
          "nic_lock"                                   # 🔗 Links to var.lock_groups
        ]
      }
    }
  }
}
```

| Field | Description |
|-------|-------------|
| `network_name` | Required; links to a key in [`var.networks`](#networks), specifying the VNet for the interface. |
| `subnet_name` | Required; links to a subnet key within the specified `network_name` in [`var.networks`](#networks). |
| `lock_groups` | Optional; if set, links to keys in [`var.lock_groups`](#lock-groups). Specifies the resource lock groups that this network interface belongs to. These lock groups override lock groups defined at the [parent VM set](#virtual-machine-set) level. |
| `private_ip` | Optional; sets a static private IP address, e.g., `10.0.0.10`. Defaults to `null` for dynamic allocation. |
| `private_ip_allocation` | Optional; defines IP assignment: `Static` or `Dynamic`. Defaults to `Dynamic`. |
| `enable_accelerated_networking` | Optional; if `true`, enables accelerated networking for better performance. Defaults to `true`. |

### Virtual Machine Set Specs

> Terraform variable: `var.virtual_machine_set_specs`

The `virtual_machine_set_specs` table defines the sizing and storage specs for each VM set in [`virtual_machine_sets`](#virtual-machine-sets), linked one-to-one by a shared key. It pairs with [`virtual_machine_sets`](#virtual-machine-sets) and [`virtual_machine_set_zone_distribution` (for custom zone adjustments)](#virtual-machine-set-zone-distribution) to complete the VM setup. In the ERD, `virtual_machine_set_specs` connects one-to-one with [`virtual_machine_sets`](#virtual-machine-sets), anchoring compute and storage details.

```hcl
virtual_machine_set_specs = {
  database = {                                # 🔑 "database" VM set
    vm_count = 3                              # There are 3 VMs in this set
    sku_size = "Standard_D4ads_v5"            # All VMs are size Standard_D4ads_v5
    os_disk = {                                
      disk_size_gb         = 128              # OS disk is 128 GiB
      storage_account_type = "Premium_LRS"    # Can be Standard_LRS, Premium_LRS, StandardSSD_ZRS, or Premium_ZRS
    }
    data_disks = {                            
      data = {                                # 🔑 "data" data disk
        disk_size_gb         = 128            # "data" disk is 128 GiB
        storage_account_type = "Premium_LRS"  # Can be Standard_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, StandardSSD_LRS or UltraSSD_LRS
      }
      logs = {                                # 🔑 "logs" data disk
        disk_size_gb         = 256            # "logs" disk is 256 GiB
        storage_account_type = "Premium_LRS"  # Can be Standard_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, StandardSSD_LRS or UltraSSD_LRS
      }
    }
  }
}
```

| Field | Description |
|-------|-------------|
| `vm_count` | Optional; sets the number of VMs in the set, e.g., `3`. Defaults to `2`. |
| `sku_size` | Required; specifies the VM SKU, e.g., `Standard_D4ads_v5`, defining compute power. |
| `os_disk` | Required; configures the OS disk with `disk_size_gb` (e.g., `128`) and `storage_account_type` (e.g., `Premium_LRS`, defaults to `PremiumV2_LRS`). |
| `data_disks` | Optional; maps data disks with `disk_size_gb` and `storage_account_type`, aligning with `var.virtual_machine_sets.data_disks` keys. |

#### Virtual Machine Set Disk Specs

> Terraform variable: `var.virtual_machine_set_specs.data_disks`

The `data_disks` subsection within [`virtual_machine_set_specs`](#virtual-machine-set-specs) outlines data disk sizes and storage types for VM sets, matching keys with [`virtual_machine_sets.data_disks`](#virtual-machine-data-disks). In the ERD, `data_disks` is a one-to-many child of [`virtual_machine_set_specs`](#virtual-machine-set-specs), tying storage specs to VM definitions.

```hcl
virtual_machine_set_specs = {
  database = {                                # 🔑 "database" VM set
                                              # Other fields...
    data_disks = {
      data = {                                # 🔑 "data" data disk
        disk_size_gb         = 128            # "data" disk is 128 GiB
        storage_account_type = "Premium_LRS"  # Can be Standard_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, StandardSSD_LRS or UltraSSD_LRS
      }
      logs = {                                # 🔑 "logs" data disk 
        disk_size_gb         = 256            # "logs" disk is 256 GiB
        storage_account_type = "Premium_LRS"   # Can be Standard_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, StandardSSD_LRS or UltraSSD_LRS
      }
    }
  }
}
```

| Field | Description |
|-------|-------------|
| `disk_size_gb` | Required; sets the data disk size in gigabytes, e.g., `128` or `256`. |
| `storage_account_type` | Optional; specifies the storage type, e.g., `Premium_LRS`. Defaults to `PremiumV2_LRS`. |

### Virtual Machine Set Zone Distribution

> Terraform variable: `var.virtual_machine_set_zone_distribution`

The `virtual_machine_set_zone_distribution` table adjusts the placement of VMs from [`virtual_machine_sets`](#virtual-machine-sets) across [Azure availability zones](https://learn.microsoft.com/azure/reliability/availability-zones-overview?tabs=azure-cli), overriding the default even distribution (across all three zones) set by `infra_map_vm_set`. It shares a one-to-one relationship with [`virtual_machine_sets`](#virtual-machine-sets) and [`virtual_machine_set_specs`](#virtual-machine-set-specs) via a common key, used only when custom zone allocations are needed, like for capacity constraints. In the ERD, `virtual_machine_set_zone_distribution` links one-to-one with [`virtual_machine_sets`](#virtual-machine-sets), tailoring zonal deployment for each set.

```hcl
virtual_machine_set_zone_distribution = {
  primary_bca_web = {  # 🔗 Links to var.virtual_machine_sets
    custom = {         # Custom distribution    
      "1" = 2          # 2 VMs in zone 1
      "2" = 8          # 8 VMs in zone 2
    }
  }
  database = {         # 🔗 Links to var.virtual_machine_sets
    even = [           # Distribute VMs evenly across zones 1 and 3
      "1",             
      "3"
    ]
  }
}
```

| Field | Description |
|-------|-------------|
| `custom` | Optional; maps zone numbers (e.g., `"1"`, `"2"`) to specific VM counts (e.g., `2`, `8`) for targeted distribution. Defaults to `null`. |
| `even` | Optional; lists zones (e.g., `["1", "3"]`) for even VM distribution across those zones. Defaults to `null`. If both `custom` and `even` are `null`, VMs spread evenly across all zones. |

### Storage Accounts

> Terraform variable: `var.storage_accounts`

The `storage_accounts` table configures [Azure storage accounts](https://learn.microsoft.com/azure/storage/common/storage-account-overview) to store data such as [blobs](https://learn.microsoft.com/azure/storage/blobs/storage-blobs-overview) and [files](https://learn.microsoft.com/azure/storage/files/storage-files-introduction). Each account specifies its [location](#locations), [resource group](#resource-groups), and [subscription](#subscriptions), with options for [access tiers](https://learn.microsoft.com/azure/storage/blobs/access-tiers-overview) and [replication](https://learn.microsoft.com/azure/storage/common/storage-redundancy). In the ERD, `storage_accounts` links one-to-one with [`subscriptions`](#subscriptions), [`locations`](#locations), and [`resource_groups`](#resource-groups), and one-to-many with [`blob_containers`](#blob-containers) and [`file_shares`](#file-shares).

```hcl
storage_accounts = {
  files = {  # 🔑 Primary key: "files"
    location_name       = "primary"      # 🔗 Links to var.locations
    resource_group_name = "shared"       # 🔗 Links to var.resource_groups
    subscription_name   = "primary"      # 🔗 Links to var.subscriptions
    name                = "appfiles"
    replication_type    = "RAGRS"
  }
}
```

| Field | Description |
|-------|-------------|
| `location_name` | Required; links to a key in [`var.locations`](#locations), setting the storage account’s Azure region. |
| `resource_group_name` | Required; links to a key in [`var.resource_groups`](#resource-groups), defining the storage account’s resource group. |
| `subscription_name` | Required; links to a key in [`var.subscriptions`](#subscriptions), tying the storage account to a subscription. |
| `name` | Optional; names the storage account, e.g., `appfiles`. Defaults to `null` (auto-generated if unset). |
| `access_tier` | Optional; sets the access tier: `Hot` or `Cool`. Defaults to `Hot`. |
| `account_tier` | Optional; sets the performance tier: `Standard` or `Premium`. Defaults to `Standard`. |
| `account_type` | Optional; specifies the account kind: `StorageV2`, `Storage`, `BlobStorage`, or `FileStorage`. Defaults to `StorageV2`. |
| `replication_type` | Optional; sets data replication: `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS`, and `RAGZRS`. Defaults to `ZRS`. |
| `allow_http_access` | Optional; if `true`, enables HTTP access. Defaults to `false` for security. |
| `include_deployment_prefix_in_name` | Optional; if `true`, prepends a deployment prefix to the name. Defaults to `true`. |
| `lock_groups` | Optional; lists lock groups for resource protection, e.g., `["main_lock"]`. Defaults to `[]`. |
| `tags` | Optional; applies key-value tags, e.g., `{ environment = "production" }`. Defaults to `{}`. |

> [!WARNING]
> We strongly recommend that you allow storage account HTTPS access only (`allow_http_access = false`). This is the default.

### Blob Containers

> Terraform variable: `var.blob_containers`

The `blob_containers` table configures [Azure Blob Storage](https://learn.microsoft.com/azure/storage/blobs/storage-blobs-overview) containers within [storage accounts](#storage-accounts) to store unstructured data like files or backups. Each container specifies its storage account and name, with an option for public access. In the ERD, `blob_containers` links one-to-one with [`storage_accounts`](#storage-accounts) via `storage_account_name`.

```hcl
blob_containers = {
  uploaded_files = {                # 🔑 Primary key: "uploaded_files"
    storage_account_name = "files"  # 🔗 Links to var.storage_accounts
    name                 = "uploaded-files"
  }
}
```

| Field | Description |
|-------|-------------|
| `storage_account_name` | Required; links to a key in [`var.storage_accounts`](#storage_accounts), specifying the storage account for the container. |
| `name` | Required; names the blob container, e.g., `uploaded-files`. |
| `enable_public_network_access` | Optional; if `true`, allows public access to the container. Defaults to `false` for security. |

### File Shares

> Terraform variable: `var.file_shares`

The `file_shares` table configures [Azure File Shares](https://learn.microsoft.com/azure/storage/files/storage-files-introduction) within [storage accounts](#storage-accounts) for shared file storage accessible via [SMB](https://learn.microsoft.com/azure/storage/files/files-smb-protocol?tabs=azure-portal) or [NFS](https://learn.microsoft.com/azure/storage/files/files-nfs-protocol) protocols. Each share specifies its storage account, name, and storage quota, with options for access tier and protocol. In the ERD, `file_shares` links one-to-one with [`storage_accounts`](#storage-accounts) via `storage_account_name`.

```hcl
file_shares = {
  uploaded_files = {                # 🔑 Primary key: "uploaded_files"
    storage_account_name = "files"  # 🔗 Links to var.storage_accounts
    name                 = "uploaded-files"
    quota_gb             = 1
  }
}
```

| Field | Description |
|-------|-------------|
| `storage_account_name` | Required; links to a key in [`var.storage_accounts`](#storage_accounts), specifying the storage account for the file share. |
| `name` | Required; names the file share, e.g., `uploaded-files`. |
| `quota_gb` | Required; sets the storage limit in gigabytes, e.g., `1`. |
| `access_tier` | Optional; sets the access tier: `Hot`, `Cool`, or `TransactionOptimized`. Defaults to `Hot`. |
| `protocol` | Optional; specifies the access protocol: `SMB` or `NFS`. Defaults to `SMB`. |

### Key Vaults

> Terraform variable: `var.key_vaults`

The `key_vaults` table configures Azure Key Vaults for secure storage of secrets, keys, and certificates, requiring a location, subscription, and resource group as its foundation. Commonly used optional fields like SKU, tags, and network ACLs enhance its setup. While broadly applicable, its design reflects Epic’s security influence and is referenced by tables like `virtual_machine_sets`. In the ERD, `key_vaults` links one-to-one with `subscriptions`, `locations`, and `resource_groups`.

```hcl
key_vaults = {
  primary = {                                # 🔑 "primary" key vault
    location_name       = "primary"          # 🔗 Links to var.locations
    subscription_name   = "main"             # 🔗 Links to var.subscriptions
    resource_group_name = "main_key_vaults"  # 🔗 Links to var.resource_groups
    sku_name            = "standard"         # Optional; standard or premium

    lock_groups = [                          # Optional
      "production_lock"                      # 🔗 Links to var.lock_groups
    ]

    tags = {
      epic-env = "production"                # Optional; custom tags
    }

    network_acls = {
      bypass         = "AzureServices"       # Optional; allow Azure services
      default_action = "Allow"               # Optional; default access rule
    }
  }
  alt = {                                    # 🔑 "alt" key vault
    location_name       = "alt"              # 🔗 Links to var.locations
    subscription_name   = "main"             # 🔗 Links to var.subscriptions
    resource_group_name = "main_key_vaults"  # 🔗 Links to var.resource_groups
    sku_name            = "standard"         # Optional; standard or premium

    lock_groups = [                          # Optional
      "non_production_lock"                  # 🔗 Links to var.lock_groups
    ]

    tags = {
      epic-env = "production"                # Optional; custom tags 
    }

    network_acls = {
      bypass         = "AzureServices"       # Optional; allow Azure services
      default_action = "Allow"               # Optional; default access rule
    }
  }
}
```

| Field | Description |
|-------|-------------|
| `location_name` | Required; links to a key in [`var.locations`](#locations), setting the vault’s Azure region. |
| `subscription_name` | Required; links to a key in [`var.subscriptions`](#subscriptions), tying the vault to a subscription. |
| `resource_group_name` | Required; links to a key in [`var.resource_groups`](#resource-groups), defining the vault’s resource group. |
| `lock_groups` | Optional; if set, links to keys in [`var.lock_groups`](#lock-groups). Specifies the resource lock groups that the vault belongs to. |
| `sku_name` | Optional; sets the vault SKU: `standard` or `premium`. Defaults to `standard`. |
| `tags` | Optional; applies key-value tags, e.g., `epic-env: production`. Defaults to `{}`. |
| `network_acls` | Optional; configures network access with `bypass` (e.g., `AzureServices`) and `default_action` (e.g., `Allow`). Defaults to `{}`. |

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
