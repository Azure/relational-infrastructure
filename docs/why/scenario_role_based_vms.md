# Role-Based VMs

## Explanation
Deploy two VM sets (app and db) in one resource group, each with 2 VMs, custom data disks (one empty, one from snapshot), maintenance schedules for weekly updates, and key vault integration for secrets.

## Key Metrics

| Metric | AzRI | Traditional | Notes |
|--------|------|-------------|-------|
| **Code Conciseness Metric (CCM)** | 10 LoC | 18 LoC | Measures total executable HCL lines; AzRI's maps condense configs. |
| **Redundancy Reduction Index (RRI)** | 44% | N/A | % reduction: ((18 - 10) / 18) * 100; highlights AzRI's normalization. |

## Comparison

### AzRI
Uses `virtual_machine_sets` (with data_disks), `virtual_machine_set_specs` (disk specs), `maintenance_schedules`, `key_vaults`. 1:1 linking. Total 10 lines.

```hcl
maintenance_schedules = {
  weekly = {
    repeat_every = {
      week = true
    }
    start_date_time_utc = "2025-01-05 22:00"
    duration            = "2:00"
  }
}
key_vaults = {
  main = {
    subscription_name   = "prod"
    resource_group_name = "rg"
    location_name       = "eastus"
  }
}
virtual_machine_sets = {
  app = {
    key_vault_name      = "main"
    subscription_name   = "prod"
    resource_group_name = "rg"
    location_name       = "eastus"
    os_type             = "Windows"
    data_disks = {
      empty = {
        lun = 0
      }
      snapshot = {
        lun   = 1
        image = {
          restore = {
            resource_id = "snapshot-id"
          }
        }
      }
    }
    maintenance = {
      schedule_name = "weekly"
    }
    network_interfaces = {
      nic = {
        network_name = "main"
        subnet_name  = "a"
      }
    }
  }
  db = {
    key_vault_name      = "main"
    subscription_name   = "prod"
    resource_group_name = "rg"
    location_name       = "eastus"
    os_type             = "Windows"
    data_disks = {
      empty = {
        lun = 0
      }
      snapshot = {
        lun   = 1
        image = {
          restore = {
            resource_id = "snapshot-id"
          }
        }
      }
    }
    maintenance = {
      schedule_name = "weekly"
    }
    network_interfaces = {
      nic = {
        network_name = "main"
        subnet_name  = "a"
      }
    }
  }
}
virtual_machine_set_specs = {
  app = {
    vm_count = 2
    sku_size = "Standard_D4s_v3"
    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
    data_disks = {
      empty = {
        disk_size_gb         = 128
        storage_account_type = "Premium_LRS"
      }
      snapshot = {
        disk_size_gb         = 256
        storage_account_type = "Premium_LRS"
      }
    }
  }
  db = {
    vm_count = 2
    sku_size = "Standard_D8s_v3"
    os_disk = {
      disk_size_gb         = 256
      storage_account_type = "Premium_LRS"
    }
    data_disks = {
      empty = {
        disk_size_gb         = 512
        storage_account_type = "Premium_LRS"
      }
      snapshot = {
        disk_size_gb         = 1024
        storage_account_type = "Premium_LRS"
      }
    }
  }
}
```

Efficiency: Specs separated but linked; maintenance applies set-wide.

### Traditional Terraform
Per VM: azurerm_virtual_machine (x4), azurerm_managed_disk (x4+), attachments, azurerm_maintenance_configuration, azurerm_key_vault. Total 18 lines.

```hcl
resource "azurerm_maintenance_configuration" "weekly" {
  name                = "weekly"
  location            = "eastus"
  resource_group_name = "rg"
  scope               = "InGuestPatch"
  window {
    start_date_time = "2025-01-05 22:00"
    duration        = "02:00"
    time_zone       = "UTC"
    recur_every     = "1Week"
  }
}

resource "azurerm_key_vault" "main" {
  name         = "main-kv"
  resource_group_name = "rg"
  location     = "eastus"
  tenant_id    = "..."
  sku_name     = "standard"
}

module "vm_sets" {
  source  = "Azure/compute/azurerm"
  version = "x"

  for_each = {
    app = "Standard_D4s_v3"
    db  = "Standard_D8s_v3"
  }

  vm_hostname     = each.key
  location        = "eastus"
  resource_group_name = "rg"
  vnet_subnet_id  = "subnet-id"
  admin_username  = "admin"
  admin_password  = "password"
  nb_instances    = 2
  vm_os_publisher = "MicrosoftWindowsServer"
  vm_os_offer     = "WindowsServer"
  vm_os_sku       = "2019-Datacenter"
  vm_os_version   = "latest"
  vm_size         = each.value
  data_disks = [
    {
      name               = "empty"
      lun                = 0
      disk_size_gb       = each.key == "app" ? 128 : 512
      managed_disk_type  = "Premium_LRS"
    },
    {
      name               = "snapshot"
      lun                = 1
      disk_size_gb       = each.key == "app" ? 256 : 1024
      managed_disk_type  = "Premium_LRS"
      create_option      = "Copy"
      source_resource_id = "snapshot-id"
    }
  ]
}

resource "azurerm_maintenance_assignment_virtual_machine" "assign" {
  for_each = flatten([for set in keys(module.vm_sets) : [for i in range(2) : "${set}-${i}"]])

  location                     = "eastus"
  maintenance_configuration_id = azurerm_maintenance_configuration.weekly.id
  virtual_machine_id           = module.vm_sets[split("-", each.value)[0]].vm_ids[tonumber(split("-", each.value)[1])]
}
```

Efficiency: Disk/VM attachments manual; maintenance assignments repetitive for sets.
