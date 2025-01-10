module "alt_bca_resource_group" {
  count    = var.cloud_specs_guide.alt.bca_web == null ? 0 : 1
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  location = var.alt_location
  name     = local.alt_bca_rg_name

  tags = {
    description = "Alternate Region Business Continuity & Access (BCA) Resources"
  }
}

module "alt_bca_web" {
  source = "../ha_vm_map"
  count  = var.cloud_specs_guide.alt.bca_web == null ? 0 : 1

  providers = {
    azurerm = azurerm
  }

  disk_profiles = {
    os_disk = {
      storage_account_type = var.cloud_specs_guide.alt.bca_web.os_disk.storage_account_type
      disk_size_gb         = var.cloud_specs_guide.alt.bca_web.os_disk.disk_size_gb
    }
  }

  virtualmachine_profiles = {
    bca_web = {
      image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      os_disk_profile    = "os_disk"
      data_disk_profiles = {}
      os_type            = "Windows"
      sku_size           = var.cloud_specs_guide.alt.bca_web.sku_size
    }
  }

  virtualmachine_sets = {
    "${local.alt_bca_web_prefix}" = {
      vm_count            = var.cloud_specs_guide.alt.bca_web.count
      location            = var.alt_location
      profile_name        = "bca_web"
      resource_group_name = module.alt_dmz_resource_group[0].name
      tags = {
        "epic-app" = "bcaweb"
        "epic-env" = var.environment
      }
      spread_across_zones        = var.cloud_specs_guide.alt.bca_web.zone_distribution.custom
      spread_evenly_across_zones = var.cloud_specs_guide.alt.bca_web.zone_distribution.even
      network_interfaces = {
        general = {
          private_ip_allocation = "Dynamic"
          subnet_id             = module.alt_dmz_vnet[0].subnets["production"].resource_id
        }
      }
    }
  }
}
