variable "deployment_prefix" {
  type     = string
  nullable = false
}

variable "include_label_tags" {
  type        = bool
  default     = false
  description = "Whether to include label tags."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of universal tags to apply to all resources."
}

variable "locations" {
  type        = map(string)
  default     = {}
  description = "A map of Azure locations in which resources will be deployed."

  validation {
    condition     = length(var.locations) > 0
    error_message = "At least one [location(s)] must be provided."
  }

  validation {
    condition = alltrue([
      for loc in values(var.locations) : contains([
        "southafricanorth",
        "eastasia",
        "southeastasia",
        "australiaeast",
        "brazilsouth",
        "canadacentral",
        "chinanorth3",
        "northeurope",
        "westeurope",
        "francecentral",
        "germanywestcentral",
        "centralindia",
        "israelcentral",
        "italynorth",
        "japaneast",
        "koreacentral",
        "norwayeast",
        "polandcentral",
        "qatarcentral",
        "swedencentral",
        "switzerlandnorth",
        "uksouth",
        "southcentralus",
        "westus2",
        "westus3",
        "centralus",
        "eastus",
        "eastus2"
      ], loc)
    ])

    error_message = <<ERROR_MESSAGE
All [locations] values must be Azure locations that support availability zones:

https://learn.microsoft.com/azure/reliability/availability-zones-region-support

For a complete list of Azure locations:

Azure CLI:        az account list-locations --query "[].name"
Azure Powershell: Get-AzLocation | Select-Object Location
ERROR_MESSAGE
  }
}

variable "networks" {
  type = map(object({
    location_name = string
    address_space = string
    name          = optional(string, null)
    peered_to     = optional(list(string), [])

    subnets = map(object({
      address_space       = string
      name                = optional(string, null)
      security_group_name = optional(string, null)
      lock_mode           = optional(string, null)

      security_rules = optional(map(object({
        name     = optional(string, null)
        priority = number
        protocol = optional(string, "*")

        allow = optional(object({
          in = optional(object({
            from = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
            to = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
          }), null)
          out = optional(object({
            from = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
            to = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
          }), null)
        }), null)

        deny = optional(object({
          in = optional(object({
            from = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
            to = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
          }), null)
          out = optional(object({
            from = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
            to = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
          }), null)
        }), null)
      })), null)
    }))
  }))
}

variable "virtual_machine_sets" {
  type = map(object({
    location_name                 = string
    name                          = optional(string, null)
    resource_group_name           = optional(string, null)
    tags                          = optional(map(string), {})
    os_type                       = optional(string, "Windows")
    disk_controller_type          = optional(string, null)
    enable_boot_diagnostics       = optional(bool, false)
    capacity_reservation_group_id = optional(string, null)
    lock_mode                     = optional(string, null)

    image = optional(object({
      id = optional(string, null) # or...
      reference = optional(object({
        offer     = string
        publisher = string
        sku       = string
        version   = string
      }), null)
    }), null)

    data_disks = optional(map(object({
      lun     = number
      caching = optional(string, "ReadWrite")
      image = optional(object({
        copy = optional(object({
          resource_id = string
        }), null) # or...
        import = optional(object({
          uri    = string
          secure = optional(bool, true)
        }), null) # or...
        platform = optional(object({
          image_reference_id = string
        }), null) # or...
        restore = optional(object({
          resource_id = string
        }), null)
      }), null)
    })), {})

    network_interfaces = map(object({
      network_name                  = string
      subnet_name                   = string
      private_ip_allocation         = optional(string, "Dynamic")
      enable_accelerated_networking = optional(bool, true)
    }))
  }))
}

variable "virtual_machine_set_zone_distribution" {
  type = map(object({
    custom = optional(map(number), null)
    even   = optional(list(string), null)
  }))

  default     = {}
  description = "The availability zone distribution configurations for [virtual_machine_sets]."
  nullable    = false
}

variable "virtual_machine_set_specs" {
  type = map(object({
    vm_count = optional(number, 2)
    sku_size = string
    data_disks = optional(map(object({
      disk_size_gb         = number
      storage_account_type = optional(string, "PremiumV2_LRS")
    })), {})
    os_disk = object({
      disk_size_gb         = number
      storage_account_type = optional(string, "PremiumV2_LRS")
    })
  }))
}
