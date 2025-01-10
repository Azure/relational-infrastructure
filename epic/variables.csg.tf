variable "cloud_specs_guide" {
  type = object({
    alt = optional(object({
      bca_web = optional(object({
        count    = number
        sku_size = string
        os_disk = object({
          storage_account_type = string
          disk_size_gb         = number
        })
        zone_distribution = object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        })
      }), null)
      hsw = optional(object({
        count    = number
        sku_size = string
        os_disk = object({
          storage_account_type = string
          disk_size_gb         = number
        })
        zone_distribution = object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        })
      }), null)
      interconnect = optional(object({
        count    = number
        sku_size = string
        os_disk = object({
          storage_account_type = string
          disk_size_gb         = number
        })
        zone_distribution = object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        })
      }), null)
      system_pulse = optional(object({
        count    = number
        sku_size = string
        os_disk = object({
          storage_account_type = string
          disk_size_gb         = number
        })
        zone_distribution = object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        })
      }), null)
      kuiper = optional(object({
        count    = number
        sku_size = string
        os_disk = object({
          storage_account_type = string
          disk_size_gb         = number
        })
        zone_distribution = object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        })
      }), null)
      mychart = optional(object({
        count    = number
        sku_size = string
        os_disk = object({
          storage_account_type = string
          disk_size_gb         = number
        })
        zone_distribution = object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        })
      }), null)
      citrix_cc = optional(object({
        count    = number
        sku_size = string
        os_disk = object({
          storage_account_type = string
          disk_size_gb         = number
        })
        zone_distribution = object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        })
      }), null)
      citrix_vda = optional(object({
        count    = number
        sku_size = string
        os_disk = object({
          storage_account_type = string
          disk_size_gb         = number
        })
        zone_distribution = object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        })
      }), null)
    }), null)
    primary = optional(object({

    }), null)
  })
}
