# ============================================================================
# EXPLAIN: This TFVARS file was generated from a hand-drawn architecture diagram
# showing a single resource group "App01" containing two VNets (AppVNet and
# DB VNet), peered together, with three VM roles: Web (3), API (3), DB (3).
# NSG rules allow Web→DB and API→DB traffic across the peering.
# ============================================================================

# REVIEW: Set this to your environment's deployment prefix (e.g., "app01", "dev", "prod")
deployment_prefix = "app01"

include_label_tags = true

# --------------------------------------------------------------------------
# Locations
# --------------------------------------------------------------------------
# EXPLAIN: The diagram doesn't specify a region. Both VNets are in the same
# resource group, suggesting a single-region deployment. Defaulting to eastus.
locations = {
  primary = "francecentral" # REVIEW: Change to your target Azure region
}

# --------------------------------------------------------------------------
# Subscriptions
# --------------------------------------------------------------------------
# EXPLAIN: The diagram shows a single resource group with no subscription
# boundaries, so I'm modeling one subscription.
subscriptions = {
  main = {
    default_resource_group_name = "app01"
    subscription_id             = "00363a64-55c1-4807-92a4-7dfe011d5222" # REVIEW: Replace with your Azure subscription ID
  }
}

# --------------------------------------------------------------------------
# Resource Groups
# --------------------------------------------------------------------------
# EXPLAIN: The outer box in the diagram is labeled "Resource Group - App01".
# Everything lives in this single resource group.
resource_groups = {
  app01 = {
    subscription_name = "main"
    location_name     = "primary"
    name              = "App01"
  }
}

# --------------------------------------------------------------------------
# Networks
# --------------------------------------------------------------------------
# EXPLAIN: Two VNets are drawn in the diagram:
#   - AppVNet (10.100.0.0/16) with "Web Subnet" and "API Subnet"
#   - DB VNet (10.200.0.0/16) with "DB Subnet"
# A dashed line labeled "Peered" connects them. Peering is configured
# bidirectionally so both sides can communicate (required for the NSG
# "can access" arrows to work).
#
# EXPLAIN: Subnet CIDR ranges are NOT in the diagram — only the VNet CIDRs
# (10.100.0.0/16 and 10.200.0.0/16) are shown. I've carved /24 subnets
# from each VNet's address space as a reasonable default.
networks = {
  app_vnet = {
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "app01"
    name                = "AppVNet"
    address_space       = "10.100.0.0/16"

    peered_to = ["db_vnet"]

    subnets = {
      web = {
        name          = "WebSubnet"
        address_space = "10.100.0.0/24" # REVIEW: Adjust subnet CIDR if your IP plan differs

        # EXPLAIN: The diagram shows "NSG Can Access" from Web → DB.
        # We apply a deny-all baseline then allow web→db explicitly.
        security_rules = [
          "deny_all_inbound_to_db",
          "allow_web_to_db"
        ]
      }

      api = {
        name          = "APISubnet"
        address_space = "10.100.1.0/24" # REVIEW: Adjust subnet CIDR if your IP plan differs

        # EXPLAIN: The diagram shows "NSG Can Access" from API → DB.
        security_rules = [
          "deny_all_inbound_to_db",
          "allow_api_to_db"
        ]
      }
    }
  }

  db_vnet = {
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "app01"
    name                = "DBVNet"
    address_space       = "10.200.0.0/16"

    peered_to = ["app_vnet"]

    subnets = {
      db = {
        name          = "DBSubnet"
        address_space = "10.200.0.0/24" # REVIEW: Adjust subnet CIDR if your IP plan differs

        # EXPLAIN: The DB subnet is the target of "can access" rules.
        # A deny-all baseline is applied, then inbound from web and api
        # subnets is explicitly allowed.
        security_rules = [
          "deny_all_inbound_to_db",
          "allow_web_to_db",
          "allow_api_to_db"
        ]
      }
    }
  }
}

# --------------------------------------------------------------------------
# Network Security Rules
# --------------------------------------------------------------------------
# EXPLAIN: The diagram has two "NSG Can Access" arrows:
#   1. Web Subnet → DB Subnet
#   2. API Subnet → DB Subnet
# The diagram doesn't specify ports or protocols, so these rules allow all
# traffic. A deny-all baseline is included so the DB subnet is locked down
# by default.
#
# REVIEW: If "can access" means specific ports only (e.g., 1433 for SQL,
# 3306 for MySQL), add a network_ports entry and set port_names on the
# allow rules below.
network_security_rules = {
  deny_all_inbound_to_db = {
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

  allow_web_to_db = {
    # EXPLAIN: Represents the "NSG Can Access" arrow from Web Subnet to DB VNet
    allow = {
      in = {
        from = {
          subnet = {
            network_name = "app_vnet"
            subnet_name  = "web"
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

  allow_api_to_db = {
    # EXPLAIN: Represents the "NSG Can Access" arrow from API Subnet to DB VNet
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
}

# --------------------------------------------------------------------------
# Key Vaults
# --------------------------------------------------------------------------
# EXPLAIN: Key vaults are required by virtual_machine_sets but aren't shown
# in the diagram. I'm creating one key vault to serve all three VM roles.
key_vaults = {
  app01 = {
    location_name       = "primary"
    subscription_name   = "main"
    resource_group_name = "app01"
    sku_name            = "standard"
  }
}

# --------------------------------------------------------------------------
# Virtual Machine Images
# --------------------------------------------------------------------------
# EXPLAIN: The diagram doesn't specify OS or images. Defaulting to Windows
# Server 2022 Datacenter for all roles. Change to Linux if needed.
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
# EXPLAIN: The diagram shows three distinct VM roles, each with 3 VMs:
#   - Web 1, Web 2, Web 3 in Web Subnet on AppVNet
#   - API 1, API 2, API 3 in API Subnet on AppVNet
#   - DB 1, DB 2, DB 3 in DB Subnet on DB VNet
# Each role maps to a virtual_machine_set with a single network interface
# attached to its respective subnet.
virtual_machine_sets = {
  web = {
    # EXPLAIN: Maps to "Web 1, Web 2, Web 3" boxes in the Web Subnet
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
    # EXPLAIN: Maps to "API 1, API 2, API 3" boxes in the API Subnet
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
    # EXPLAIN: Maps to "DB 1, DB 2, DB 3" boxes in the DB Subnet
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

# --------------------------------------------------------------------------
# Virtual Machine Set Specs
# --------------------------------------------------------------------------
# EXPLAIN: The diagram shows 3 VMs per role but doesn't specify SKU sizes,
# disk sizes, or performance requirements. I've used reasonable defaults:
#   - Standard_D4as_v5 (4 vCPU, 16 GB RAM) for web and api
#   - Standard_E4as_v5 (4 vCPU, 32 GB RAM) for db (memory-optimized)
# Adjust to match your workload requirements.
virtual_machine_set_specs = {
  web = {
    vm_count = 3
    sku_size = "Standard_D4as_v5" # REVIEW: Adjust SKU to match workload requirements

    os_disk = {
      disk_size_gb         = 128          # REVIEW: Adjust OS disk size
      storage_account_type = "Premium_LRS"
    }
  }

  api = {
    vm_count = 3
    sku_size = "Standard_D4as_v5" # REVIEW: Adjust SKU to match workload requirements

    os_disk = {
      disk_size_gb         = 128          # REVIEW: Adjust OS disk size
      storage_account_type = "Premium_LRS"
    }
  }

  db = {
    vm_count = 3
    sku_size = "Standard_E4as_v5" # REVIEW: Adjust SKU — memory-optimized chosen for DB role

    os_disk = {
      disk_size_gb         = 256          # REVIEW: Adjust OS disk size for DB workload
      storage_account_type = "Premium_LRS"
    }

    # EXPLAIN: DB VMs likely need data disks for database storage but the
    # diagram doesn't specify. Uncomment and configure if needed:
    # data_disk_groups = {
    #   data = {
    #     disk_count           = 2
    #     disk_size_gb         = 512
    #     storage_account_type = "Premium_LRS"
    #   }
    #   logs = {
    #     disk_count           = 1
    #     disk_size_gb         = 256
    #     storage_account_type = "Premium_LRS"
    #   }
    # }
  }
}
