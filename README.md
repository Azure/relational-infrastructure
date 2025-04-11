# Epic on Azure Terraform Stack

This repository provides a Terraform module stack for deploying Epic on Azure, aligned with the Epic on Azure Well-Architected Framework (WAF) and built on Microsoft’s Azure Verified Modules (AVM). It’s designed to be both private and reusable, offering a flexible framework for managing Azure infrastructure across multiple subscriptions and workloads. The stack includes a private module for Epic-specific healthcare deployments (e.g., Hyperspace, MyChart) while keeping lower layers generic for broader use cases.

Each layer of the stack is a Terraform module, built to work independently or together. You can use the full stack for Epic on Azure or tap into individual layers for other projects, like setting up reliable virtual machines or organizing complex networks. Infrastructure is defined with table-like map variables (e.g., `infra_map`), which act like a blueprint to connect resources such as networks, VMs, and key vaults.

The stack delivers:
- **Privacy**: Only the Epic module contains sensitive healthcare configurations, kept private for compliance.
- **Reusability**: Lower layers are public and adaptable for any Azure infrastructure project.
- **Simplicity**: Modular design lets you choose the level of complexity you need, from basic resources to full deployments.

## Architecture

The stack is organized as a set of Terraform modules, each adding a specific piece of the puzzle. Think of it as a toolkit: you can use one tool or the whole set, depending on your goal. Here’s how the layers work together:

### 1. Foundation: Azure Verified Modules (AVM)
This layer uses AVM resource modules to deploy core Azure resources like virtual machines, storage accounts, and key vaults, following Microsoft’s best practices for reliability and security. For bigger setups, it includes AVM pattern modules for things like hub-and-spoke networking or Azure Landing Zone (ALZ) configurations, which help with governance and scalability. It’s the starting point for any solid Azure infrastructure, ensuring everything’s built on a trusted, standardized base.

### 2. infra_map_vm_set: Virtual Machine Patterns
The `infra_map_vm_set` module makes it easy to deploy groups of virtual machines that are reliable by default. It’s based on common patterns, like organizing VMs by role (e.g., web servers, databases) and spreading them across Azure Availability Zones for high availability. Using Virtual Machine Scale Sets (VMSS Flex), it supports workloads that need to stay up and running, even during outages. While it draws inspiration from Epic’s 20+ workloads (like MyChart), it’s generic enough for any project needing organized, resilient VMs across regions like Canada Central or France Central.

### 3. infra_map and subscription_infra_map: Infrastructure Blueprints
These modules (`infra_map` and `subscription_infra_map`) let you describe your entire Azure environment like a database. Resources—networks, subscriptions, VM sets, key vaults—are organized into Terraform maps, where each map is like a table with a unique key (e.g., `network_name` or `subscription_name`). For example, you might define a network called `primary_dmz` and link it to a subscription called `main`, with tags to track everything. This setup makes it simple to manage complex, multi-subscription environments and tweak configurations without breaking things. These modules are public and reusable for any Azure project.

### 4. Epic Module: Private Healthcare Deployments
The Epic module is the private capstone, designed specifically for Epic on Azure. It uses the lower layers to deploy healthcare workloads like Hyperspace or MyChart, with preconfigured settings that meet Epic’s requirements (e.g., security, performance). You can customize it with parameters, like choosing regions or sizing VMs, but this layer stays private to protect sensitive details. It’s the only module that mentions Epic, keeping everything else open for broader use.

## Infrastructure Map Model

This section unveils the core of the stack: a normalized infrastructure map that organizes your Azure environment like a database. Built with Terraform map variables, it creates a relational model that seamlessly ties together networks, virtual machine sets, subscriptions, key vaults, and more. It’s the blueprint that keeps everything structured and adaptable, whether you’re deploying Epic on Azure or crafting a custom infrastructure project. The private Epic module builds on this foundation, adding tailored configurations for healthcare workloads like Hyperspace or MyChart.

To bring these connections to life, we’ve included an **entity-relationship diagram (ERD)** below, showing how resources link up—with details like cardinality (e.g., one subscription to many resource groups). This model drives the stack’s flexibility, letting you reuse generic layers for any Azure setup while keeping Epic’s sensitive configurations locked down in its private module.

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

The `locations` table defines the Azure regions where your infrastructure lives, like `eastus` or `westus`. It’s the starting point for placing resources geographically, ensuring they align with [Azure’s global regions](https://learn.microsoft.com/azure/reliability/regions-list) for availability and compliance. In the entity-relationship diagram (ERD), `locations` acts as a reference point, linking one-to-many with tables like networks or virtual machine sets to specify where they’re deployed.

```hcl
locations = {
  primary = "eastus"  # A valid Azure region
  alt     = "westus"  # A valid Azure region
}
```

## Subscriptions

> Terraform variable: `var.subscriptions`

The `subscriptions` table organizes your [Azure subscriptions](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-setup-guide/organize-resources#management-levels-and-hierarchy), acting as a control center for grouping resources across your environment. Each subscription connects to resource groups and Terraform providers, setting the scope for your infrastructure. In the entity-relationship diagram (ERD), `subscriptions` serves as a central hub, with one-to-many links to tables like `resource_groups` and `networks`, ensuring resources stay aligned.

```hcl
subscriptions = {
  production = {
    default_resource_group_name      = "production"          # 🔑 Links to var.resource_groups
    private_link_resource_group_name = "production_networks" # 🔑 Optional; links to var.resource_groups
    subscription_slot                = "az_subscription_1"   # Ties to an azurerm provider
  }
  non_production = {
    default_resource_group_name      = "non_production"          
    private_link_resource_group_name = "non_production_networks"
    subscription_slot                = "az_subscription_2"
  }
}
```

| Field | Description |
|-------|-------------|
| `default_resource_group_name` | Links to a key in [`var.resource_groups`](#resource-groups). Defines the primary resource group for the subscription. |
| `private_link_resource_group_name` | Optional; if set, links to a key in [`var.resource_groups`](#resource-groups) for private link resources. Defaults to `default_resource_group_name` if unset. |
| `subscription_slot` | References a named [`azurerm` provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) alias (e.g., `az_subscription_1` to `az_subscription_10`), tying to a specific Azure subscription. |

## Resource Groups

> Terraform variable: `var.resource_groups`

The `resource_groups` table defines the [Azure resource groups](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-setup-guide/organize-resources#management-levels-and-hierarchy) that bundle related resources together in your environment. Each resource group ties to a subscription and, optionally, a location, organizing assets like networks or VMs. In the entity-relationship diagram (ERD), `resource_groups` links one-to-one with `subscriptions` and optionally to `locations`, acting as a container for other resources.

```hcl
resource_groups = {
  production = {
    subscription_name = "production"  # 🔑 Links to var.subscriptions
    location_name     = "primary"    # 🔑 Optional; links to var.locations
    name              = "production" # Resource group name in Azure
  }
  non_production = {
    subscription_name = "non_production"
    location_name     = "alt"
    name              = "non-production"
  }
}
```

| Field | Description |
|-------|-------------|
| `subscription_name` | Links to a key in [`var.subscriptions`](#subscriptions). Defines the subscription this resource group belongs to. |
| `location_name` | Optional; if set, links to a key in [`var.locations`](#locations). Specifies the Azure region for the resource group. Defaults to the first location in `var.locations` if unset. |
| `name` | The name of the resource group as it appears in Azure, used to identify it. |

## Virtual Machine Extensions

> Terraform variable: `var.virtual_machine_extensions`

The `virtual_machine_extensions` table sets up extensions for Azure VMs, adding capabilities like monitoring or management tools. It defines settings such as publisher, type, and versioning for consistent application across your environment. In the ERD, `virtual_machine_extensions` links one-to-many to `virtual_machine_sets`, letting multiple VM sets share the same extension config—like the Azure Monitor Agent for Windows shown below.

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

The `networks` table defines the virtual networks (VNets) in your Azure environment, distinct from external networks (e.g., on-premises or other clouds) covered in `var.external_networks`. It organizes VNets and their subnets, linking them to subscriptions, locations, and resource groups. In the ERD, `networks` connects one-to-many with `subnets` and one-to-one with `subscriptions`, `locations`, and `resource_groups`, anchoring your network topology.

```hcl
networks = {
  main = {
    location_name       = "primary"      # 🔑 Links to var.locations
    subscription_name   = "production"   # 🔑 Links to var.subscriptions
    resource_group_name = "production"   # 🔑 Links to var.resource_groups
    name                = "main-vnet"    # Optional; defaults to key "main" if unset
    address_space       = "10.0.0.0/16"
    subnets = {
      subnet_a = {
        name            = "subnet-a"     # Optional; defaults to key "subnet_a" if unset
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

| Field | Description |
|-------|-------------|
| `location_name` | Links to a key in [`var.locations`](#locations), specifying the Azure region for the VNet. |
| `subscription_name` | Links to a key in [`var.subscriptions`](#subscriptions), tying the VNet to a subscription. |
| `resource_group_name` | Links to a key in [`var.resource_groups`](#resource-groups), defining the resource group for the VNet. |
| `name` | Optional; names the VNet in Azure, defaults to the map key (e.g., `main`) if not set. |
| `address_space` | Defines the VNet’s IP address range, e.g., `10.0.0.0/16`. |
| `subnets` | A nested map of subnets, each with a `name` (optional, defaults to key) and `address_space` for its IP range. |

#### Peerings

> Terraform variable: `var.networks.peered_to`

The `peerings` section within the `networks` table sets up virtual network peerings, connecting VNets within this model (`var.networks`) or to external networks (`var.external_networks`). It enables traffic flow between networks, like linking a primary and alternate VNet. In the ERD, `peerings` represents a many-to-many relationship between `networks`, or between `networks` and `external_networks`, facilitating flexible network topologies.

```hcl
networks = {
  main = {
    # Other fields like location_name, subnets...
    peered_to = [
      "alt"  # Links to the "alt" network in var.networks
    ]
  }
  alt = {
    # Other fields like location_name, subnets...
    peered_to = [
      "main"  # Links to the "main" network in var.networks
    ]
  }
}
```

| Field | Description |
|-------|-------------|
| `peered_to` | A list of network keys from [`var.networks`](#networks) or [`var.external_networks`](#external-networks) to peer with. For `external_networks`, a valid Azure `resource_id` is required. |

#### Routes

> Terraform variable: `var.networks.subnets.routes`

The `routes` section within `subnets` of the `networks` table defines custom routing rules for each subnet, controlling traffic flow to gateways, the Internet, appliances, or nowhere (dropped). Routes can target fixed CIDR address spaces or reference networks and subnets from `var.networks` or `var.external_networks`. In the ERD, `routes` is a child of `subnets`, with one-to-many relationships to destinations, enabling precise traffic management. A route table is created only for networks with defined `routes`.

```hcl
networks = {
  main = {
    # Other fields like location_name...
    subnets = {
      route_traffic = {
        destined_for = {
          address_space = "192.168.1.0/24"  # Target address space
        }
        to_gateway = true                   # Route to network gateway
      },
      internet_traffic = {
        destined_for = {
          network_name = "alt"            # Target network in var.networks
        }
        to_internet = true                # Route to Internet
      },
      appliance_traffic = {
        destined_for = {
          network_name = "alt"            # Target network
          subnet_name  = "subnet_b"       # Target subnet
        }
        to_appliance = {
          ip_address = "192.168.1.1"      # Route to appliance
        }
      },
      drop_traffic = {
        destined_for = {
          address_space = "0.0.0.0/0"     # Target Internet
        }
        to_nowhere = true                 # Drop traffic
      }
    }
  }
  alt = {
    # Other fields...
    subnets = {
      subnet_b = {
        # Subnet details...
      }
    }
  }
}
```

| Field | Description |
|-------|-------------|
| `destined_for` | Specifies the traffic destination, either as a CIDR `address_space` (e.g., `192.168.1.0/24`) or a `network_name` and optional `subnet_name` from [`var.networks`](#networks) or [`var.external_networks`](#external-networks). |
| `to_gateway` | If `true`, routes traffic to a network gateway. |
| `to_internet` | If `true`, routes traffic to the Internet. |
| `to_appliance` | Routes traffic to a virtual appliance, requiring an `ip_address` (e.g., `192.168.1.1`). |
| `to_nowhere` | If `true`, drops traffic entirely. |

#### Security Rules

> Terraform variable: `var.networks.subnets.security_rules`

The `security_rules` section within `subnets` of the `networks` table configures layer 4 network security group (NSG) rules for each subnet, controlling inbound and outbound traffic. Using a fluent syntax, rules define source/destination addresses, ports, and priorities, referencing `var.networks` or `var.external_networks`. In the ERD, `security_rules` is a child of `subnets`, with one-to-many links to traffic rules. An NSG is created for each network, regardless of whether `security_rules` is defined.

```hcl
networks = {
  main = {
    # Other fields like location_name...
    subnets = {
      subnet_a = {
        security_rules = {
          allow_static_in = {
            priority = "100"                    # NSG priority
            allow = { in = { from = {           # Inbound rule
              address_space = "192.168.1.0/24"  # From address space
              port_range    = "443"             # On port 443
            }}}
          },
          allow_network_in = {
            priority = "110"                    # NSG priority
            allow = { in = { from = {           # Inbound rule
              network = {
                network_name = "alt"            # From alt network
                port_range   = "100-200"        # Ports 100-200
              }
            }}}
          },
          deny_subnet_in = {
            priority = "120"                    # NSG priority
            deny = { in = { from = {            # Inbound rule
              subnet = {
                network_name = "alt"            # From alt network
                subnet_name  = "subnet_b"       # From subnet_b
                port_range   = "443"            # On port 443
              }
            }}}
          },
          allow_static_out = {
            priority = "130"                    # NSG priority
            allow = { out = { to = {            # Outbound rule
              address_space = "192.168.1.0/24"  # To address space
              port_range    = "443"             # On port 443
            }}}
          },
          deny_network_out = {
            priority = "140"                    # NSG priority
            deny = { out = { to = {             # Outbound rule
              network = {
                network_name = "alt"            # To alt network
                port_range   = "443"            # On port 443
              }
            }}}
          },
          allow_subnet_out = {
            priority = "150"                    # NSG priority
            allow = { out = { to = {            # Outbound rule
              subnet = {
                network_name = "alt"            # To alt network
                subnet_name  = "subnet_b"       # To subnet_b
                port_range   = "443"            # On port 443
              }
            }}}
          }
        }
      }
    }
  }
  alt = {
    # Other fields...
    subnets = {
      subnet_b = {
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

### Virtual Machine Sets

> Terraform variable: `var.virtual_machine_sets`

The `virtual_machine_sets` table configures groups of highly available VMs that share the same role, workload, and availability settings. By default, VMs are spread evenly across Azure availability zones, with custom distribution possible via `var.virtual_machine_set_zone_distribution`. Related specs like VM count, SKU, and disks are defined in `var.virtual_machine_set_specs`, maintaining a 1:1 link with `virtual_machine_sets` and `virtual_machine_set_zone_distribution` to streamline automation. In the ERD, `virtual_machine_sets` connects one-to-one with `subscriptions`, `resource_groups`, `locations`, and `key_vaults`, and one-to-many with `extensions` and `data_disks`.

```hcl
virtual_machine_sets = {
  database = {
    key_vault_name                    = "primary"      # 🔑 Links to var.key_vaults
    location_name                     = "primary"      # 🔑 Links to var.locations
    resource_group_name               = "production"   # 🔑 Links to var.resource_groups
    subscription_name                 = "production"   # 🔑 Links to var.subscriptions
    name                              = "db"           # Prefix for all VMs in this set
    include_deployment_prefix_in_name = true           # Apply var.deployment_prefix? Default: false
    tags = {
      role = "database"                                # Optional; tags all VMs
    }
    extensions = [
      "azure_monitor"                                  # 🔑 Optional; links to var.virtual_machine_extensions
    ]
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
| `name` | Prefixes all VMs in the set, used in their Azure names. |
| `include_deployment_prefix_in_name` | If `true`, prepends `var.deployment_prefix` to resource names. Default: `false`. |
| `tags` | Optional; applies key-value tags to all VMs, e.g., `role: database`. |
| `extensions` | Optional; lists extensions from [`var.virtual_machine_extensions`](#virtual-machine-extensions) to apply. |
| `os_type` | Specifies the OS: `Windows` or `Linux`. |
| `disk_controller_type` | Optional; sets disk controller to `SCSI` or `NVMe` based on VM SKU. |
| `enable_boot_diagnostics` | If `true`, enables boot diagnostics. Default: `false`. |

#### Virtual Machine Image

> Terraform variable: `var.virtual_machine_sets.image`

The `image` section within `virtual_machine_sets` selects the OS image for VMs, ensuring consistency and compliance. It can reference a custom/shared image by ID or an Azure Marketplace image by details like offer and publisher. In the ERD, `image` is a child of `virtual_machine_sets`, with a one-to-one relationship.

```hcl
virtual_machine_sets = {
  database = {
    # Other fields...
    image = {
      reference = {
        offer     = "UbuntuServer"  # Image offer name
        publisher = "Canonical"     # Image publisher
        sku       = "18.04-LTS"     # Image edition
        version   = "latest"        # Image version
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

### Virtual Machine Data Disks

> Terraform variable: `var.virtual_machine_sets.data_disks`

The `data_disks` section within `virtual_machine_sets` configures optional data disks for VMs, specifying their attachment and content source. Each disk defines a logical unit number (LUN), caching mode, and an optional image source, such as a snapshot, VHD file, Marketplace image, restored disk, or empty disk. In the ERD, `data_disks` is a one-to-many child of `virtual_machine_sets`, supporting multiple disks per VM set for versatile storage needs.

```hcl
virtual_machine_sets = {
  database = {
    # Other fields...
    data_disks = {
      copy_disk = {
        lun                          = 0
        caching                      = "ReadWrite"
        enable_public_network_access = false
        image = {
          copy = {
            resource_id = "/subscriptions/12345678/resourceGroups/rg/providers/Microsoft.Compute/disks/source-disk"
          }
        }
      }
      import_disk = {
        lun = 1
        image = {
          import = {
            uri    = "https://storage.blob.core.windows.net/vhds/sample.vhd"
            secure = true
          }
        }
      }
      platform_disk = {
        lun = 2
        image = {
          platform = {
            image_reference_id = "/subscriptions/12345678/resourceGroups/rg/providers/Microsoft.Compute/images/ubuntu-18.04"
          }
        }
      }
      restore_disk = {
        lun = 3
        image = {
          restore = {
            resource_id = "/subscriptions/12345678/resourceGroups/rg/providers/Microsoft.Compute/snapshots/backup-snapshot"
          }
        }
      }
      empty_disk = {
        lun = 4
        image = null  # Creates an empty disk
      }
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

#### Virtual Machine Network Interfaces

> Terraform variable: `var.virtual_machine_sets.network_interfaces`

The `network_interfaces` section within `virtual_machine_sets` configures the network connectivity for VMs, linking them to specific VNets and subnets. Each interface specifies a network, subnet, and IP settings, with options for accelerated networking. In the ERD, `network_interfaces` is a one-to-many child of `virtual_machine_sets`, with one-to-one links to `networks` and `subnets` via `network_name` and `subnet_name`, ensuring each VM set connects to the right network topology.

```hcl
virtual_machine_sets = {
  database = {
    # Other fields...
    network_interfaces = {
      primary_nic = {
        network_name                  = "main"         # Links to var.networks
        subnet_name                   = "subnet_a"     # Links to var.networks.main.subnets
        private_ip                    = "10.0.0.10"    # Optional; static IP
        private_ip_allocation         = "Static"       # Optional; static or dynamic
        enable_accelerated_networking = true           # Optional; boost network performance
      }
    }
  }
}
```

| Field | Description |
|-------|-------------|
| `network_name` | Required; links to a key in [`var.networks`](#networks), specifying the VNet for the interface. |
| `subnet_name` | Required; links to a subnet key within the specified `network_name` in [`var.networks`](#networks). |
| `private_ip` | Optional; sets a static private IP address, e.g., `10.0.0.10`. Defaults to `null` for dynamic allocation. |
| `private_ip_allocation` | Optional; defines IP assignment: `Static` or `Dynamic`. Defaults to `Dynamic`. |
| `enable_accelerated_networking` | Optional; if `true`, enables accelerated networking for better performance. Defaults to `true`. |

### Virtual Machine Set Specs

> Terraform variable: `var.virtual_machine_set_specs`

The `virtual_machine_set_specs` table defines the sizing and storage specs for each VM set in `virtual_machine_sets`, linked one-to-one by a shared key. Crafted with flexibility for any Azure deployment, its design draws inspiration from Epic on Azure’s detailed VM and disk requirements, ensuring precision across use cases. It pairs with `virtual_machine_sets` and `virtual_machine_set_zone_distribution` (for custom zone adjustments) to complete the VM setup. In the ERD, `virtual_machine_set_specs` connects one-to-one with `virtual_machine_sets`, anchoring compute and storage details.

```hcl
virtual_machine_set_specs = {
  database = {
    vm_count = 3
    sku_size = "Standard_D4ads_v5"
    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
    data_disks = {
      data = {
        disk_size_gb         = 128
        storage_account_type = "Premium_LRS"
      }
      logs = {
        disk_size_gb         = 256
        storage_account_type = "Premium_LRS"
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

### Virtual Machine Set Disk Specs

> Terraform variable: `var.virtual_machine_set_specs.data_disks`

The `data_disks` subsection within `virtual_machine_set_specs` outlines data disk sizes and storage types for VM sets, matching keys with `virtual_machine_sets.data_disks`. Built for broad Azure use, it’s shaped by Epic’s need for detailed disk configurations, ensuring consistency across deployments. In the ERD, `data_disks` is a one-to-many child of `virtual_machine_set_specs`, tying storage specs to VM definitions.

```hcl
virtual_machine_set_specs = {
  database = {
    # Other fields...
    data_disks = {
      data = {
        disk_size_gb         = 128
        storage_account_type = "Premium_LRS"
      }
      logs = {
        disk_size_gb         = 256
        storage_account_type = "Premium_LRS"
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

The `virtual_machine_set_zone_distribution` table adjusts the placement of VMs from `virtual_machine_sets` across Azure availability zones, overriding the default even distribution (across all three zones) set by `infra_map_vm_set`. It shares a one-to-one relationship with `virtual_machine_sets` and `virtual_machine_set_specs` via a common key, used only when custom zone allocations are needed, like for capacity constraints. In the ERD, `virtual_machine_set_zone_distribution` links one-to-one with `virtual_machine_sets`, tailoring zonal deployment for each set.

```hcl
virtual_machine_set_zone_distribution = {
  primary_bca_web = {
    custom = {
      "1" = 2  # 2 VMs in zone 1
      "2" = 8  # 8 VMs in zone 2
    }
  }
  database = {
    even = [
      "1",   # Distribute VMs evenly across zones 1 and 3
      "3"
    ]
  }
}
```

| Field | Description |
|-------|-------------|
| `custom` | Optional; maps zone numbers (e.g., `"1"`, `"2"`) to specific VM counts (e.g., `2`, `8`) for targeted distribution. Defaults to `null`. |
| `even` | Optional; lists zones (e.g., `["1", "3"]`) for even VM distribution across those zones. Defaults to `null`. If both `custom` and `even` are `null`, VMs spread evenly across all zones. |

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
