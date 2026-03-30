# ============================================================================
# EXPLAIN: This TFVARS file was generated from a hand-drawn architecture diagram
# showing a single VNet ("Main VNet") with three subnets (Web, API, DB), each
# containing 3 VMs distributed across two availability zones (AZ1 and AZ2) in
# a 2:1 split. NSG rules restrict API to HTTPS (443) only and DB to SQL only.
# A "DR Mirror Deployment" is peered to the main VNet as a separate environment.
# ============================================================================

# REVIEW: Set this to your environment's deployment prefix
deployment_prefix = "azapp"

# --------------------------------------------------------------------------
# Locations
# --------------------------------------------------------------------------
# EXPLAIN: The diagram doesn't specify a region. Single-region deployment
# with a DR mirror peered externally. Defaulting to eastus.
locations = {
  primary = "eastus" # REVIEW: Change to your target Azure region
}

# --------------------------------------------------------------------------
# Subscriptions
# --------------------------------------------------------------------------
# EXPLAIN: No subscription boundaries shown in the diagram. Modeling as one.
subscriptions = {
  main = {
    default_resource_group_name = "app"
    subscription_id             = "00000000-0000-0000-0000-000000000000" # REVIEW: Replace with your Azure subscription ID
  }
}

# --------------------------------------------------------------------------
# Resource Groups
# --------------------------------------------------------------------------
# EXPLAIN: No resource group is labeled in the diagram. Creating a default one.
resource_groups = {
  app = {
    subscription_name = "main"
    location_name     = "primary"
    name              = "app-rg" # REVIEW: Adjust resource group name
  }
}

# --------------------------------------------------------------------------
# Network Ports
# --------------------------------------------------------------------------
# EXPLAIN: The diagram explicitly calls out two port-level restrictions:
#   - "Allow only 443" on the API Subnet
#   - "Allow only SQL" on the DB Subnet
# SQL port defaults to 1433 (MSSQL). Change if using MySQL (3306) or
# PostgreSQL (5432).
network_ports = {
  https = "443"
  sql   = "1433" # REVIEW: Change to 3306 (MySQL) or 5432 (PostgreSQL) if applicable
}

# --------------------------------------------------------------------------
# Network Security Rules
# --------------------------------------------------------------------------
# EXPLAIN: The diagram has two NSG annotations at the bottom:
#   1. "Allow only 443" with an arrow pointing up into the API Subnet
#   2. "Allow only SQL" with an arrow pointing up into the DB Subnet
# I interpret "allow only" as: deny all inbound by default, then permit
# only the specified port. The source isn't specified in the diagram, so
# I'm allowing from within the VNet (the web tier calls API, API calls DB).
network_security_rules = {
  deny_all_inbound_to_api = {
    # EXPLAIN: Baseline deny-all for API subnet so "allow only 443" is enforced
    deny = {
      in = {
        to = {
          subnet = {
            network_name = "main"
            subnet_name  = "api"
          }
        }
      }
    }
  }

  allow_https_to_api = {
    # EXPLAIN: "Allow only 443" — permits HTTPS inbound to API subnet
    port_names = ["https"]
    protocol   = "Tcp"
    allow = {
      in = {
        to = {
          subnet = {
            network_name = "main"
            subnet_name  = "api"
          }
        }
      }
    }
  }

  deny_all_inbound_to_db = {
    # EXPLAIN: Baseline deny-all for DB subnet so "allow only SQL" is enforced
    deny = {
      in = {
        to = {
          subnet = {
            network_name = "main"
            subnet_name  = "db"
          }
        }
      }
    }
  }

  allow_sql_to_db = {
    # EXPLAIN: "Allow only SQL" — permits SQL inbound to DB subnet.
    # Source not specified in diagram; allowing from API subnet since that's
    # the typical app→db flow. Adjust if web also needs direct DB access.
    port_names = ["sql"]
    protocol   = "Tcp"
    allow = {
      in = {
        from = {
          subnet = {
            network_name = "main"
            subnet_name  = "api" # REVIEW: Change if other subnets also need DB access
          }
        }
        to = {
          subnet = {
            network_name = "main"
            subnet_name  = "db"
          }
        }
      }
    }
  }
}

# --------------------------------------------------------------------------
# External Networks
# --------------------------------------------------------------------------
# EXPLAIN: The "DR Mirror Deployment" box on the right is peered to the main
# VNet but drawn as a separate, opaque environment. I'm modeling it as an
# external network since it's outside this deployment's scope. If the DR
# environment is also managed by AzRI, this would be a separate infra_map
# deployment instead.
external_networks = {
  dr_mirror = {
    address_space = "10.200.0.0/16" # REVIEW: Set to the actual DR environment address space
    resource_id   = null             # REVIEW: Set to the DR VNet's Azure resource ID to enable peering
                                     # e.g., "/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/..."
    subnets = {}
  }
}

# --------------------------------------------------------------------------
# Networks
# --------------------------------------------------------------------------
# EXPLAIN: The diagram shows one VNet ("Main VNet") with three subnets
# side by side: Web Subnet, API Subnet, DB Subnet. The VNet is peered to
# the DR Mirror Deployment. No CIDR ranges are specified in the diagram.
networks = {
  main = {
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "app"
    name                = "main-vnet"
    address_space       = "10.100.0.0/16" # REVIEW: Adjust VNet CIDR range

    peered_to = ["dr_mirror"]

    subnets = {
      web = {
        name          = "WebSubnet"
        address_space = "10.100.0.0/24" # REVIEW: Adjust subnet CIDR

        # EXPLAIN: No NSG annotations on Web Subnet in the diagram.
        # Leaving open — add security_rules here if web should be restricted too.
      }

      api = {
        name          = "APISubnet"
        address_space = "10.100.1.0/24" # REVIEW: Adjust subnet CIDR

        # EXPLAIN: "Allow only 443" — deny-all baseline then allow HTTPS
        security_rules = [
          "deny_all_inbound_to_api",
          "allow_https_to_api"
        ]
      }

      db = {
        name          = "DBSubnet"
        address_space = "10.100.2.0/24" # REVIEW: Adjust subnet CIDR

        # EXPLAIN: "Allow only SQL" — deny-all baseline then allow SQL from API
        security_rules = [
          "deny_all_inbound_to_db",
          "allow_sql_to_db"
        ]
      }
    }
  }
}

# --------------------------------------------------------------------------
# Key Vaults
# --------------------------------------------------------------------------
# EXPLAIN: Required by VM sets but not in the diagram. One key vault for all roles.
key_vaults = {
  app = {
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "app"
    sku_name            = "standard"
  }
}

# --------------------------------------------------------------------------
# Virtual Machine Images
# --------------------------------------------------------------------------
# EXPLAIN: OS not specified in diagram. Defaulting to Windows Server 2022.
virtual_machine_images = {
  windows_2022 = {
    reference = {
      offer     = "WindowsServer"          # REVIEW: Change if using a different OS
      publisher = "MicrosoftWindowsServer"  # REVIEW: e.g., "Canonical" for Ubuntu
      sku       = "2022-datacenter-g2"      # REVIEW: e.g., "22_04-lts-gen2" for Ubuntu
      version   = "latest"
    }
  }
}

# --------------------------------------------------------------------------
# Virtual Machine Sets
# --------------------------------------------------------------------------
# EXPLAIN: Three roles, each with 3 VMs, all in Main VNet on their
# respective subnets. Same structure as diagram: Web, API, DB.
virtual_machine_sets = {
  web = {
    image_name          = "windows_2022"
    key_vault_name      = "app"
    location_name       = "primary"
    resource_group_name = "app"
    subscription_name   = "main"
    name                = "web"
    os_type             = "Windows" # REVIEW: Change to "Linux" if applicable

    network_interfaces = {
      primary = {
        network_name = "main"
        subnet_name  = "web"
      }
    }
  }

  api = {
    image_name          = "windows_2022"
    key_vault_name      = "app"
    location_name       = "primary"
    resource_group_name = "app"
    subscription_name   = "main"
    name                = "api"
    os_type             = "Windows" # REVIEW: Change to "Linux" if applicable

    network_interfaces = {
      primary = {
        network_name = "main"
        subnet_name  = "api"
      }
    }
  }

  db = {
    image_name          = "windows_2022"
    key_vault_name      = "app"
    location_name       = "primary"
    resource_group_name = "app"
    subscription_name   = "main"
    name                = "db"
    os_type             = "Windows" # REVIEW: Change to "Linux" if applicable

    network_interfaces = {
      primary = {
        network_name = "main"
        subnet_name  = "db"
      }
    }
  }
}

# --------------------------------------------------------------------------
# Virtual Machine Set Specs
# --------------------------------------------------------------------------
# EXPLAIN: 3 VMs per role (visible count from diagram). SKUs and disk sizes
# are not specified — using reasonable defaults per role.
virtual_machine_set_specs = {
  web = {
    vm_count = 3
    sku_size = "Standard_D4as_v5" # REVIEW: Adjust SKU to match workload

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }

  api = {
    vm_count = 3
    sku_size = "Standard_D4as_v5" # REVIEW: Adjust SKU to match workload

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }

  db = {
    vm_count = 3
    sku_size = "Standard_E4as_v5" # REVIEW: Memory-optimized for DB role

    os_disk = {
      disk_size_gb         = 256
      storage_account_type = "Premium_LRS"
    }
  }
}

# --------------------------------------------------------------------------
# Virtual Machine Set Zone Distribution
# --------------------------------------------------------------------------
# EXPLAIN: The diagram explicitly shows two availability zones (AZ1 and AZ2)
# on the left side, with a dashed line splitting VMs:
#   - AZ1: Web1, Web2 | API1, API2 | DB1, DB2 (top two rows)
#   - AZ2: Web3       | API3       | DB3       (bottom row)
# This is a 2:1 custom distribution across 2 zones — NOT the default even
# distribution across 3 zones. Applied identically to all three VM sets.
virtual_machine_set_zone_distribution = {
  web = {
    custom = {
      "1" = 2 # 2 VMs in AZ1
      "2" = 1 # 1 VM in AZ2
    }
  }

  api = {
    custom = {
      "1" = 2 # 2 VMs in AZ1
      "2" = 1 # 1 VM in AZ2
    }
  }

  db = {
    custom = {
      "1" = 2 # 2 VMs in AZ1
      "2" = 1 # 1 VM in AZ2
    }
  }
}
