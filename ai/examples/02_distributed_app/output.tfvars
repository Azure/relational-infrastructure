# ============================================================================
# EXPLAIN: This TFVARS file was generated from a hand-drawn architecture
# diagram showing:
#   - "Main VNet" with 3 subnets: Web, API, DB — each with 3 VMs
#   - Availability zone distribution: AZ1 = 2 VMs, AZ2 = 1 VM per role
#   - NSG: API Subnet allows only port 443; DB Subnet allows only SQL
#   - "DR Mirror Deployment" peered to Main VNet — exact same architecture
#     replicated in a second region
#
# The diagram was interpreted as a three-tier application with:
#   - All 3 subnets in a single VNet (not separate VNets like the first diagram)
#   - Port-specific NSGs on API and DB subnets
#   - A full DR copy in another region, peered bidirectionally
#
# Traffic flow (applies identically to both primary and DR):
#   Any → Web    (unrestricted — no NSG on Web Subnet)
#   Any → API    (port 443 only)
#   Any → DB     (SQL port only)
# ============================================================================

# REVIEW: Set this to your environment's deployment prefix
deployment_prefix = "app02"

# --- Locations ---------------------------------------------------------------
# EXPLAIN: Two regions required — one for primary, one for DR. The diagram
# doesn't name either region.
locations = {
  primary = "eastus"  # REVIEW: Change to your primary Azure region
  dr      = "westus2" # REVIEW: Change to your DR Azure region
}

# --- Subscriptions -----------------------------------------------------------
# EXPLAIN: No subscription boundaries in the diagram. Single subscription
# for both primary and DR.
subscriptions = {
  main = {
    default_resource_group_name = "primary"
    subscription_id             = "00000000-0000-0000-0000-000000000000" # REVIEW: Replace with your Azure subscription ID
  }
}

# --- Resource Groups ---------------------------------------------------------
# EXPLAIN: No resource group labels in the diagram. Creating one per region
# to keep primary and DR resources separated.
resource_groups = {
  primary = {
    subscription_name = "main"
    location_name     = "primary"
    name              = "primary"
  }

  dr = {
    subscription_name = "main"
    location_name     = "dr"
    name              = "dr"
  }
}

# --- Networks ----------------------------------------------------------------
# EXPLAIN: The diagram shows a single "Main VNet" containing all 3 subnets
# (Web, API, DB) — unlike the first diagram which had separate VNets.
# The DR side is an exact mirror. VNet CIDRs are not labeled in the diagram.
#
# Peering: dashed line labeled "Peered" between Main VNet and DR. Configured
# bidirectionally so cross-region traffic flows in both directions (e.g., DB
# replication, failover orchestration).
networks = {
  main_vnet = {
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "primary"
    name                = "MainVNet"
    address_space       = "10.0.0.0/16" # REVIEW: VNet CIDR not in diagram

    peered_to = ["dr_vnet"] # EXPLAIN: Dashed "Peered" line to DR

    subnets = {
      web = {
        name          = "WebSubnet"
        address_space = "10.0.0.0/24" # REVIEW: Subnet CIDR not in diagram
      }

      api = {
        name                = "APISubnet"
        address_space       = "10.0.1.0/24" # REVIEW: Subnet CIDR not in diagram
        security_group_name = "main_api_nsg" # EXPLAIN: "Allow only 443" annotation
      }

      db = {
        name                = "DBSubnet"
        address_space       = "10.0.2.0/24" # REVIEW: Subnet CIDR not in diagram
        security_group_name = "main_db_nsg"  # EXPLAIN: "Allow only SQL" annotation
      }
    }
  }

  # EXPLAIN: Exact mirror of main_vnet in the DR region. Same subnets,
  # same NSG structure, different address space to avoid overlap on peering.
  dr_vnet = {
    location_name       = "dr"
    subscription_name   = "main"
    resource_group_name = "dr"
    name                = "DRVNet"
    address_space       = "10.1.0.0/16" # REVIEW: DR VNet CIDR not in diagram

    peered_to = ["main_vnet"] # EXPLAIN: Bidirectional peering with primary

    subnets = {
      web = {
        name          = "WebSubnet"
        address_space = "10.1.0.0/24" # REVIEW: Subnet CIDR not in diagram
      }

      api = {
        name                = "APISubnet"
        address_space       = "10.1.1.0/24" # REVIEW: Subnet CIDR not in diagram
        security_group_name = "dr_api_nsg"   # EXPLAIN: Mirror of primary NSG
      }

      db = {
        name                = "DBSubnet"
        address_space       = "10.1.2.0/24" # REVIEW: Subnet CIDR not in diagram
        security_group_name = "dr_db_nsg"    # EXPLAIN: Mirror of primary NSG
      }
    }
  }
}

# --- Network Ports -----------------------------------------------------------
# EXPLAIN: The diagram specifies two port restrictions by name:
#   - "Allow only 443" → HTTPS
#   - "Allow only SQL" → SQL Server (1433 assumed)
network_ports = {
  https = "443"
  mssql = "1433" # REVIEW: Use "3306" for MySQL or "5432" for PostgreSQL
}

# --- Network Security Rules --------------------------------------------------
# EXPLAIN: The diagram shows dashed brackets below API and DB subnets with
# port-restriction annotations. These are "what traffic is allowed" rules,
# not "where from" rules — the diagram does not specify a source.
#
# Rules are created in pairs: allow the named port, then deny everything else.
# Each pair is duplicated for primary and DR (mirrored).
#
# REVIEW: To restrict traffic sources (e.g., only Web→API on 443, only
# API→DB on SQL), add a "from" block to the allow rules below.

# --- Primary API rules ---
network_security_rules = {
  allow_443_to_main_api = {
    # EXPLAIN: "Allow only 443" annotation under API Subnet.
    port_names = ["https"]
    protocol   = "Tcp"
    allow = {
      in = {
        to = {
          subnet = {
            network_name = "main_vnet"
            subnet_name  = "api"
          }
        }
      }
    }
  }

  deny_all_to_main_api = {
    # EXPLAIN: Baseline deny — only 443 gets through.
    deny = {
      in = {
        to = {
          subnet = {
            network_name = "main_vnet"
            subnet_name  = "api"
          }
        }
      }
    }
  }

  # --- Primary DB rules ---
  allow_sql_to_main_db = {
    # EXPLAIN: "Allow only SQL" annotation under DB Subnet.
    port_names = ["mssql"]
    protocol   = "Tcp"
    allow = {
      in = {
        to = {
          subnet = {
            network_name = "main_vnet"
            subnet_name  = "db"
          }
        }
      }
    }
  }

  deny_all_to_main_db = {
    # EXPLAIN: Baseline deny — only SQL gets through.
    deny = {
      in = {
        to = {
          subnet = {
            network_name = "main_vnet"
            subnet_name  = "db"
          }
        }
      }
    }
  }

  # --- DR API rules (mirror) ---
  allow_443_to_dr_api = {
    # EXPLAIN: Mirror of primary — same "Allow only 443" rule for DR.
    port_names = ["https"]
    protocol   = "Tcp"
    allow = {
      in = {
        to = {
          subnet = {
            network_name = "dr_vnet"
            subnet_name  = "api"
          }
        }
      }
    }
  }

  deny_all_to_dr_api = {
    deny = {
      in = {
        to = {
          subnet = {
            network_name = "dr_vnet"
            subnet_name  = "api"
          }
        }
      }
    }
  }

  # --- DR DB rules (mirror) ---
  allow_sql_to_dr_db = {
    # EXPLAIN: Mirror of primary — same "Allow only SQL" rule for DR.
    port_names = ["mssql"]
    protocol   = "Tcp"
    allow = {
      in = {
        to = {
          subnet = {
            network_name = "dr_vnet"
            subnet_name  = "db"
          }
        }
      }
    }
  }

  deny_all_to_dr_db = {
    deny = {
      in = {
        to = {
          subnet = {
            network_name = "dr_vnet"
            subnet_name  = "db"
          }
        }
      }
    }
  }
}

# --- Network Security Groups -------------------------------------------------
# EXPLAIN: Four NSGs total — one per restricted subnet, mirrored across
# primary and DR. Web Subnet has no NSG (no restriction shown in diagram).
network_security_groups = {
  main_api_nsg = {
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "primary"
    security_rules = [
      "allow_443_to_main_api",
      "deny_all_to_main_api"
    ]
  }

  main_db_nsg = {
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "primary"
    security_rules = [
      "allow_sql_to_main_db",
      "deny_all_to_main_db"
    ]
  }

  # EXPLAIN: DR mirror — identical rule structure, different region.
  dr_api_nsg = {
    location_name       = "dr"
    subscription_name   = "main"
    resource_group_name = "dr"
    security_rules = [
      "allow_443_to_dr_api",
      "deny_all_to_dr_api"
    ]
  }

  dr_db_nsg = {
    location_name       = "dr"
    subscription_name   = "main"
    resource_group_name = "dr"
    security_rules = [
      "allow_sql_to_dr_db",
      "deny_all_to_dr_db"
    ]
  }
}

# --- Key Vaults --------------------------------------------------------------
# EXPLAIN: Required by virtual_machine_sets but not in diagram. One per
# region — key vaults cannot span regions.
key_vaults = {
  primary_kv = {
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "primary"
    sku_name            = "standard"
  }

  dr_kv = {
    location_name       = "dr"
    subscription_name   = "main"
    resource_group_name = "dr"
    sku_name            = "standard"
  }
}

# --- Virtual Machine Images --------------------------------------------------
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

# --- Virtual Machine Sets (Primary) -----------------------------------------
# EXPLAIN: 3 roles × 3 VMs each, all in Main VNet.
#   Web 1–3 → Web Subnet
#   API 1–3 → API Subnet
#   DB 1–3  → DB Subnet
virtual_machine_sets = {
  web = {
    image_name          = "windows_2022"
    key_vault_name      = "primary_kv"
    location_name       = "primary"
    resource_group_name = "primary"
    subscription_name   = "main"
    name                = "web"
    os_type             = "Windows" # REVIEW: Change to "Linux" if applicable

    network_interfaces = {
      primary = {
        network_name = "main_vnet"
        subnet_name  = "web"
      }
    }
  }

  api = {
    image_name          = "windows_2022"
    key_vault_name      = "primary_kv"
    location_name       = "primary"
    resource_group_name = "primary"
    subscription_name   = "main"
    name                = "api"
    os_type             = "Windows" # REVIEW: Change to "Linux" if applicable

    network_interfaces = {
      primary = {
        network_name = "main_vnet"
        subnet_name  = "api"
      }
    }
  }

  db = {
    image_name          = "windows_2022"
    key_vault_name      = "primary_kv"
    location_name       = "primary"
    resource_group_name = "primary"
    subscription_name   = "main"
    name                = "db"
    os_type             = "Windows" # REVIEW: Change to "Linux" if applicable

    network_interfaces = {
      primary = {
        network_name = "main_vnet"
        subnet_name  = "db"
      }
    }
  }

  # --- Virtual Machine Sets (DR Mirror) ------------------------------------
  # EXPLAIN: Exact mirror of primary — same roles, same VM counts, same
  # subnet placement, different region.
  dr_web = {
    image_name          = "windows_2022"
    key_vault_name      = "dr_kv"
    location_name       = "dr"
    resource_group_name = "dr"
    subscription_name   = "main"
    name                = "web"
    os_type             = "Windows" # REVIEW: Change to "Linux" if applicable

    network_interfaces = {
      primary = {
        network_name = "dr_vnet"
        subnet_name  = "web"
      }
    }
  }

  dr_api = {
    image_name          = "windows_2022"
    key_vault_name      = "dr_kv"
    location_name       = "dr"
    resource_group_name = "dr"
    subscription_name   = "main"
    name                = "api"
    os_type             = "Windows" # REVIEW: Change to "Linux" if applicable

    network_interfaces = {
      primary = {
        network_name = "dr_vnet"
        subnet_name  = "api"
      }
    }
  }

  dr_db = {
    image_name          = "windows_2022"
    key_vault_name      = "dr_kv"
    location_name       = "dr"
    resource_group_name = "dr"
    subscription_name   = "main"
    name                = "db"
    os_type             = "Windows" # REVIEW: Change to "Linux" if applicable

    network_interfaces = {
      primary = {
        network_name = "dr_vnet"
        subnet_name  = "db"
      }
    }
  }
}

# --- Virtual Machine Set Specs -----------------------------------------------
# EXPLAIN: 3 VMs per role (visible in diagram). SKU/disk not specified.
#   Web/API: Standard_D4as_v5 (general purpose)
#   DB:      Standard_E4as_v5 (memory-optimized)
# DR specs are identical (mirror).
virtual_machine_set_specs = {
  web = {
    vm_count = 3
    sku_size = "Standard_D4as_v5" # REVIEW: Adjust SKU to match workload

    os_disk = {
      disk_size_gb         = 128           # REVIEW: Adjust OS disk size
      storage_account_type = "Premium_LRS"
    }
  }

  api = {
    vm_count = 3
    sku_size = "Standard_D4as_v5" # REVIEW: Adjust SKU to match workload

    os_disk = {
      disk_size_gb         = 128           # REVIEW: Adjust OS disk size
      storage_account_type = "Premium_LRS"
    }
  }

  db = {
    vm_count = 3
    sku_size = "Standard_E4as_v5" # REVIEW: Memory-optimized for DB role

    os_disk = {
      disk_size_gb         = 256           # REVIEW: Larger disk for DB workload
      storage_account_type = "Premium_LRS"
    }
  }

  # DR mirror — identical specs
  dr_web = {
    vm_count = 3
    sku_size = "Standard_D4as_v5" # REVIEW: Adjust SKU to match workload

    os_disk = {
      disk_size_gb         = 128           # REVIEW: Adjust OS disk size
      storage_account_type = "Premium_LRS"
    }
  }

  dr_api = {
    vm_count = 3
    sku_size = "Standard_D4as_v5" # REVIEW: Adjust SKU to match workload

    os_disk = {
      disk_size_gb         = 128           # REVIEW: Adjust OS disk size
      storage_account_type = "Premium_LRS"
    }
  }

  dr_db = {
    vm_count = 3
    sku_size = "Standard_E4as_v5" # REVIEW: Memory-optimized for DB role

    os_disk = {
      disk_size_gb         = 256           # REVIEW: Larger disk for DB workload
      storage_account_type = "Premium_LRS"
    }
  }
}

# --- Virtual Machine Set Zone Distribution -----------------------------------
# EXPLAIN: The diagram explicitly shows availability zone layout:
#   AZ1 (dashed lines spanning rows 1–2): 2 VMs per role
#   AZ2 (dashed lines spanning row 3):    1 VM per role
# This custom distribution applies to all 6 VM sets (primary + DR mirror).
virtual_machine_set_zone_distribution = {
  web = {
    custom = {
      "1" = 2 # EXPLAIN: Web 1, Web 2 in AZ1
      "2" = 1 # EXPLAIN: Web 3 in AZ2
    }
  }

  api = {
    custom = {
      "1" = 2 # EXPLAIN: API 1, API 2 in AZ1
      "2" = 1 # EXPLAIN: API 3 in AZ2
    }
  }

  db = {
    custom = {
      "1" = 2 # EXPLAIN: DB 1, DB 2 in AZ1
      "2" = 1 # EXPLAIN: DB 3 in AZ2
    }
  }

  # DR mirror — identical zone distribution
  dr_web = {
    custom = {
      "1" = 2
      "2" = 1
    }
  }

  dr_api = {
    custom = {
      "1" = 2
      "2" = 1
    }
  }

  dr_db = {
    custom = {
      "1" = 2
      "2" = 1
    }
  }
}
