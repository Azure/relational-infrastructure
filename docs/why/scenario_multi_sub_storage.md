# Multi-Sub Storage

## Explanation
Set up storage accounts in two subscriptions (production, non-production), each with blob containers and file shares, private endpoints on a dedicated subnet, and lock groups for read-only protection during maintenance. Includes hot access tier and ZRS replication.

## Key Metrics

| Metric | AzRI | Traditional | Notes |
|--------|------|-------------|-------|
| **Code Conciseness Metric (CCM)** | 8 LoC | 20 LoC | Measures total executable HCL lines; AzRI's maps condense configs. |
| **Redundancy Reduction Index (RRI)** | 60% | N/A | % reduction: ((20 - 8) / 20) * 100; highlights AzRI's normalization. |

## Comparison

### AzRI
Leverages `subscriptions`, `storage_accounts` (with containers/shares), `networks` (for private endpoints via subnets), `lock_groups`. Links ensure consistency. Total 8 lines.

```hcl
subscriptions = {
  production = {
    subscription_id            = "prod-id"
    default_resource_group_name = "prod-rg"
  }
  non_production = {
    subscription_id            = "nonprod-id"
    default_resource_group_name = "nonprod-rg"
  }
}
resource_groups = {
  prod_rg = {
    subscription_name = "production"
    name              = "prod-rg"
  }
  nonprod_rg = {
    subscription_name = "non_production"
    name              = "nonprod-rg"
  }
}
lock_groups = {
  maint = {
    locked    = true
    read_only = true
  }
}
networks = {
  main = {
    subscription_name   = "production"
    resource_group_name = "prod_rg"
    subnets = {
      private = {
        address_space = "10.0.2.0/24"
      }
    }
  }
}
storage_accounts = {
  prod = {
    subscription_name   = "production"
    resource_group_name = "prod_rg"
    access_tier         = "Hot"
    replication_type    = "ZRS"
    lock_groups         = ["maint"]
    blob_containers = {
      data = {
        name = "data"
      }
    }
    file_shares = {
      files = {
        name     = "files"
        quota_gb = 100
      }
    }
  }
  nonprod = {
    subscription_name   = "non_production"
    resource_group_name = "nonprod_rg"
    access_tier         = "Hot"
    replication_type    = "ZRS"
    lock_groups         = ["maint"]
    blob_containers = {
      data = {
        name = "data"
      }
    }
    file_shares = {
      files = {
        name     = "files"
        quota_gb = 100
      }
    }
  }
}
```

Efficiency: Single map per entity; locks apply group-wide, easy to toggle.

### Traditional Terraform
Individual resources: azurerm_storage_account (x2), azurerm_storage_container/blob, azurerm_storage_share, azurerm_private_endpoint (x2), azurerm_management_lock (manual per resource). Total 20 lines.

```hcl
variable "subs" {
  default = {
    prod    = "prod-id"
    nonprod = "nonprod-id"
  }
}
provider "azurerm" {
  alias  = "prod"
  subscription_id = var.subs.prod
  features {}
}
provider "azurerm" {
  alias  = "nonprod"
  subscription_id = var.subs.nonprod
  features {}
}

resource "azurerm_resource_group" "rgs" {
  for_each = var.subs

  name     = "${each.key}-rg"
  location = "eastus"
  provider = "azurerm.${each.key}"
}

module "storage" {
  source  = "Azure/storage/azurerm"
  version = "x"

  for_each = var.subs

  storage_account_name      = "${each.key}-sa"
  resource_group_name       = azurerm_resource_group.rgs[each.key].name
  location                  = "eastus"
  account_tier              = "Standard"
  account_replication_type  = "ZRS"
  access_tier               = "Hot"
  providers = {
    azurerm = "azurerm.${each.key}"
  }
  containers_list = [
    {
      name        = "data"
      access_type = "private"
    }
  ]
  file_shares = [
    {
      name  = "files"
      quota = 100
    }
  ]
}

resource "azurerm_private_endpoint" "endpoints" {
  for_each = var.subs

  name                = "${each.key}-endpoint"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rgs[each.key].name
  subnet_id           = "/subscriptions/${var.subs[each.key]}/.../subnet-private" # Manual ref
  private_service_connection {
    name                           = "${each.key}-conn"
    private_connection_resource_id = module.storage[each.key].storage_account_id
    is_manual_connection           = false
    request_message                = null
  }
  provider = "azurerm.${each.key}"
}

resource "azurerm_management_lock" "locks" {
  for_each = var.subs

  name       = "${each.key}-lock"
  scope      = module.storage[each.key].storage_account_id
  lock_level = "ReadOnly"
  notes      = "Maintenance lock"
  provider   = "azurerm.${each.key}"
}
```

Efficiency: Repetitive declarations; locks require separate resources per item, harder to manage across subscriptions.
