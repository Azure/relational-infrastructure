# ============================================================================
# EXPLAIN: This TFVARS file was generated from a hand-drawn architecture
# diagram showing a standard three-tier application:
#   - A single resource group "App01"
#   - Two VNets: AppVNet (10.100.0.0/16) and DB VNet (10.200.0.0/16)
#   - AppVNet contains Web Subnet (3 VMs) and API Subnet (3 VMs)
#   - DB VNet contains DB Subnet (3 VMs)
#   - VNets are peered (bidirectional)
#   - NSG-controlled peering boundary (annotation between VNets)
#   - Explicit "NSG Can Access" arrow: API Subnet → DB Subnet
#
# Three-tier traffic flow:
#   Web → API  (same VNet, unrestricted)
#   API → DB   (cross-peering, NSG-allowed)
#   Web ✗ DB   (denied — no allow rule exists)
# ============================================================================

# REVIEW: Set this to your environment's deployment prefix
deployment_prefix = "app01"

# --- Locations ---------------------------------------------------------------
# EXPLAIN: The diagram doesn't specify a region. Both VNets live in the same
# resource group, implying a single-region deployment. Defaulting to eastus.
locations = {
  primary = "eastus" # REVIEW: Change to your target Azure region
}

# --- Subscriptions -----------------------------------------------------------
# EXPLAIN: No subscription boundaries are shown in the diagram. Modeling
# everything under a single subscription.
subscriptions = {
  main = {
    default_resource_group_name = "app01"
    subscription_id             = "00000000-0000-0000-0000-000000000000" # REVIEW: Replace with your Azure subscription ID
  }
}

# --- Resource Groups ---------------------------------------------------------
# EXPLAIN: The outer box in the diagram is labeled "Resource Group - App01".
# All resources live in this single resource group.
resource_groups = {
  app01 = {
    subscription_name = "main"
    location_name     = "primary"
    name              = "App01"
  }
}

# --- Networks ----------------------------------------------------------------
# EXPLAIN: Two VNets are drawn in the diagram:
#   - AppVNet (10.100.0.0/16) with "Web Subnet" and "API Subnet"
#   - DB VNet (10.200.0.0/16) with "DB Subnet"
# A dashed line labeled "Peered" connects them. Peering is configured
# bidirectionally so API→DB traffic can flow (request and response).
#
# EXPLAIN: Subnet CIDRs are NOT shown in the diagram — only the VNet-level
# CIDRs (10.100.0.0/16 and 10.200.0.0/16) are explicit. I carved /24
# subnets from each VNet's space as a reasonable default.
networks = {
  app_vnet = {
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "app01"
    name                = "AppVNet"
    address_space       = "10.100.0.0/16" # EXPLAIN: Explicit in diagram

    peered_to = ["db_vnet"] # EXPLAIN: Dashed "Peered" line in diagram

    subnets = {
      web = {
        name          = "WebSubnet"
        address_space = "10.100.0.0/24" # REVIEW: Subnet CIDR not in diagram — adjust to your IP plan
      }

      api = {
        name          = "APISubnet"
        address_space = "10.100.1.0/24" # REVIEW: Subnet CIDR not in diagram — adjust to your IP plan
      }
    }
  }

  db_vnet = {
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "app01"
    name                = "DBVNet"
    address_space       = "10.200.0.0/16" # EXPLAIN: Explicit in diagram — labeled "DB VNet - 10.200.0.0/16"

    peered_to = ["app_vnet"] # EXPLAIN: Bidirectional peering required for API→DB request/response

    subnets = {
      db = {
        name                = "DBSubnet"
        address_space       = "10.200.0.0/24" # REVIEW: Subnet CIDR not in diagram — adjust to your IP plan
        security_group_name = "db_nsg"         # EXPLAIN: "NSG Can Access" annotations confirm NSG controls DB access
      }
    }
  }
}

# --- Network Ports -----------------------------------------------------------
# EXPLAIN: The diagram doesn't specify ports or protocols for the NSG rules.
# Defining common database ports here for easy future refinement.
# Uncomment and add port_names to the allow rule below if you want
# port-specific filtering.
# network_ports = {
#   mssql    = "1433"  # REVIEW: Uncomment if DB is SQL Server
#   mysql    = "3306"  # REVIEW: Uncomment if DB is MySQL
#   postgres = "5432"  # REVIEW: Uncomment if DB is PostgreSQL
# }

# --- Network Security Rules --------------------------------------------------
# EXPLAIN: The diagram has two "NSG Can Access" annotations:
#
#   1. Between the VNets (below "Peered"): stacked text reading "NSG Can
#      Access". This annotates the peered boundary, confirming NSGs control
#      cross-VNet traffic.
#
#   2. Bottom of the diagram: "NSG Can Access" with a curved arrow from
#      the API Subnet area sweeping right toward DB VNet. This is the
#      explicit directional flow: API → DB.
#
# Only the API subnet has a directional arrow to DB. Web has no arrow to DB,
# which in a deny-all model is an implicit deny. This matches the classic
# three-tier pattern: Web → API → DB.
#
# REVIEW: If API→DB should be limited to specific ports (e.g., 1433 for
# SQL Server, 3306 for MySQL, 5432 for PostgreSQL), uncomment network_ports
# above and add port_names to the allow rule.
network_security_rules = {
  allow_api_to_db = {
    # EXPLAIN: Maps the curved "NSG Can Access" arrow at the bottom of
    # the diagram: API Subnet → DB Subnet. This is the sole permitted
    # cross-peering flow.
    allow = {
      in = {
        from = {
          subnet = {
            network_name = "app_vnet"
            subnet_name  = "api"
          }
        }
        to = {
          subnet = {
            network_name = "db_vnet"
            subnet_name  = "db"
          }
        }
      }
    }
  }

  deny_all_inbound_to_db = {
    # EXPLAIN: Baseline deny-all so the DB subnet is closed by default.
    # The "NSG Can Access" annotation on the peered boundary confirms
    # NSGs control this connection. Without an explicit allow, Web VMs
    # (and anything else) cannot reach DB.
    deny = {
      in = {
        to = {
          subnet = {
            network_name = "db_vnet"
            subnet_name  = "db"
          }
        }
      }
    }
  }
}

# --- Network Security Groups -------------------------------------------------
# EXPLAIN: NSG applied to the DB subnet. The allow rule for API is evaluated
# first (ordered list); the deny-all catches everything else — including
# Web VMs, which have no explicit allow.
network_security_groups = {
  db_nsg = {
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "app01"

    security_rules = [
      "allow_api_to_db",       # Permit API → DB
      "deny_all_inbound_to_db" # Block everything else
    ]
  }
}

# --- Key Vaults --------------------------------------------------------------
# EXPLAIN: Key vaults are required by virtual_machine_sets (for admin
# credential storage) but are not shown in the diagram. Creating one
# shared key vault for all three VM roles in the same resource group.
key_vaults = {
  app01 = {
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "app01"
    sku_name            = "standard"
  }
}

# --- Virtual Machine Images --------------------------------------------------
# EXPLAIN: OS is not specified in the diagram. Defaulting to Windows Server
# 2022 Datacenter Gen2 for all roles. Change to Linux if needed.
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

# --- Virtual Machine Sets ----------------------------------------------------
# EXPLAIN: The diagram shows three distinct VM roles, each with 3 VMs:
#   - Web 1, Web 2, Web 3 → in Web Subnet on AppVNet
#   - API 1, API 2, API 3 → in API Subnet on AppVNet
#   - DB 1, DB 2, DB 3   → in DB Subnet on DB VNet
# Each role maps to a virtual_machine_set with a single NIC on its subnet.
#
# Three-tier traffic flow:
#   Web → API (same VNet, no NSG barrier)
#   API → DB  (cross-peering, allowed by NSG)
#   Web ✗ DB  (blocked by deny-all on DB subnet)
virtual_machine_sets = {
  web = {
    # EXPLAIN: Maps to "Web 1, Web 2, Web 3" boxes in the Web Subnet.
    image_name          = "windows_2022"
    key_vault_name      = "app01"
    location_name       = "primary"
    resource_group_name = "app01"
    subscription_name   = "main"
    name                = "web"
    os_type             = "Windows" # REVIEW: Change to "Linux" if applicable

    network_interfaces = {
      primary = {
        network_name = "app_vnet"
        subnet_name  = "web"
      }
    }
  }

  api = {
    # EXPLAIN: Maps to "API 1, API 2, API 3" boxes in the API Subnet.
    # API is the sole gateway to DB — the only role with NSG-allowed
    # cross-peering access to DB VNet.
    image_name          = "windows_2022"
    key_vault_name      = "app01"
    location_name       = "primary"
    resource_group_name = "app01"
    subscription_name   = "main"
    name                = "api"
    os_type             = "Windows" # REVIEW: Change to "Linux" if applicable

    network_interfaces = {
      primary = {
        network_name = "app_vnet"
        subnet_name  = "api"
      }
    }
  }

  db = {
    # EXPLAIN: Maps to "DB 1, DB 2, DB 3" boxes in the DB Subnet.
    # Isolated in its own VNet; only reachable from API via NSG allow rule.
    image_name          = "windows_2022"
    key_vault_name      = "app01"
    location_name       = "primary"
    resource_group_name = "app01"
    subscription_name   = "main"
    name                = "db"
    os_type             = "Windows" # REVIEW: Change to "Linux" if applicable

    network_interfaces = {
      primary = {
        network_name = "db_vnet"
        subnet_name  = "db"
      }
    }
  }
}

# --- Virtual Machine Set Specs -----------------------------------------------
# EXPLAIN: The diagram shows 3 VMs per role but doesn't specify SKU sizes,
# disk sizes, or performance tiers. Defaults:
#   - Web/API: Standard_D4as_v5 (4 vCPU, 16 GB RAM) — general purpose
#   - DB: Standard_E4as_v5 (4 vCPU, 32 GB RAM) — memory-optimized for DB
virtual_machine_set_specs = {
  web = {
    vm_count = 3 # EXPLAIN: 3 VMs visible in diagram (Web 1, Web 2, Web 3)
    sku_size = "Standard_D4as_v5" # REVIEW: Adjust SKU to match workload

    os_disk = {
      disk_size_gb         = 128           # REVIEW: Adjust OS disk size
      storage_account_type = "Premium_LRS"
    }
  }

  api = {
    vm_count = 3 # EXPLAIN: 3 VMs visible in diagram (API 1, API 2, API 3)
    sku_size = "Standard_D4as_v5" # REVIEW: Adjust SKU to match workload

    os_disk = {
      disk_size_gb         = 128           # REVIEW: Adjust OS disk size
      storage_account_type = "Premium_LRS"
    }
  }

  db = {
    vm_count = 3 # EXPLAIN: 3 VMs visible in diagram (DB 1, DB 2, DB 3)
    sku_size = "Standard_E4as_v5" # REVIEW: Memory-optimized SKU chosen for DB role

    os_disk = {
      disk_size_gb         = 256           # REVIEW: Larger OS disk for DB workload
      storage_account_type = "Premium_LRS"
    }
  }
}
