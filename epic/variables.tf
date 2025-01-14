variable "deployment_prefix" {
  type     = string
  nullable = false
}

variable "environment" {
  type        = string
  default     = "production"
  description = "The environment in which the Epic resources will be deployed."
  nullable    = false
}

variable "primary_location" {
  type        = string
  description = <<DESCRIPTION
The Azure location in which resources will be deployed.
The selected location must support availability zones.

The following locations support availability zones:

https://learn.microsoft.com/azure/reliability/availability-zones-region-support

For a complete list of Azure locations:

Azure CLI:        az account list-locations --query "[].name"
Azure Powershell: Get-AzLocation | Select-Object Location
    DESCRIPTION
  nullable    = true

  validation {
    condition = ((var.primary_location == null) || (contains(
      [
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
      ],
    lower(var.primary_location))))

    error_message = <<ERROR_MESSAGE
[primary_location] must be a valid Azure location which supports availability zones.

The following locations support availability zones:

https://learn.microsoft.com/azure/reliability/availability-zones-region-support

For a complete list of Azure locations:

Azure CLI:        az account list-locations --query "[].name"
Azure Powershell: Get-AzLocation | Select-Object Location
ERROR_MESSAGE
  }
}

variable "alt_location" {
  type        = string
  description = <<DESCRIPTION
The Azure location in which resources will be deployed.
The selected location must support availability zones.

The following locations support availability zones:

https://learn.microsoft.com/azure/reliability/availability-zones-region-support

For a complete list of Azure locations:

Azure CLI:        az account list-locations --query "[].name"
Azure Powershell: Get-AzLocation | Select-Object Location
    DESCRIPTION
  nullable    = false

  validation {
    condition = ((var.alt_location == null) || (contains(
      [
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
      ],
    lower(var.alt_location))))

    error_message = <<ERROR_MESSAGE
[alt_location] must be a valid Azure location which supports availability zones.

The following locations support availability zones:

https://learn.microsoft.com/azure/reliability/availability-zones-region-support

For a complete list of Azure locations:

Azure CLI:        az account list-locations --query "[].name"
Azure Powershell: Get-AzLocation | Select-Object Location
ERROR_MESSAGE
  }
}

variable "alt_networks" {
  type = object({
    dmz = object({
      space = string
      subnets = object({
        firewall_space       = string
        production_space     = string
        non_production_space = string
      })
    })
    shared_infra = object({
      space = string
      subnets = object({
        gateway_space    = string
        management_space = string
      })
    })
    main = object({
      space = string
      subnets = object({
        odb_space    = string
        wss_space    = string
        cogito_space = string
      })
    })
    hyperspace = object({
      space = string
      subnets = object({
        hyperspace_space = string
      })
    })
    hyperspace_web = object({
      space = string
      subnets = object({
        hyperspace_web_space = string
      })
    })
  })

  default = {
    dmz = {
      space = "10.0.0.0/16"
      subnets = {
        firewall_space       = "10.0.0.0/24"
        production_space     = "10.0.1.0/24"
        non_production_space = "10.0.2.0/24"
      }
    }
    shared_infra = {
      space = "10.1.0.0/16"
      subnets = {
        gateway_space    = "10.1.0.0/24"
        management_space = "10.1.1.0/24"
      }
    }
    main = {
      space = "10.2.0.0/16"
      subnets = {
        odb_space    = "10.2.0.0/24"
        wss_space    = "10.2.1.0/24"
        cogito_space = "10.2.2.0/24"
      }
    }
    hyperspace = {
      space = "10.3.0.0/16"
      subnets = {
        hyperspace_space = "10.3.0.0/24"
      }
    }
    hyperspace_web = {
      space = "10.4.0.0/16"
      subnets = {
        hyperspace_web_space = "10.4.0.0/24"
      }
    }
  }
}

variable "primary_networks" {
  type = object({
    dmz = object({
      space = string
      subnets = object({
        firewall_space       = string
        production_space     = string
        non_production_space = string
      })
    })
    shared_infra = object({
      space = string
      subnets = object({
        gateway_space    = string
        management_space = string
      })
    })
    main = object({
      space = string
      subnets = object({
        odb_space    = string
        wss_space    = string
        cogito_space = string
      })
    })
    hyperspace = object({
      space = string
      subnets = object({
        hyperspace_space = string
      })
    })
    hyperspace_web = object({
      space = string
      subnets = object({
        hyperspace_web_space = string
      })
    })
  })

  default = {
    dmz = {
      space = "10.10.0.0/16"
      subnets = {
        firewall_space       = "10.10.0.0/24"
        production_space     = "10.10.1.0/24"
        non_production_space = "10.10.2.0/24"
      }
    }
    shared_infra = {
      space = "10.11.0.0/16"
      subnets = {
        gateway_space    = "10.11.0.0/24"
        management_space = "10.11.1.0/24"
      }
    }
    main = {
      space = "10.12.0.0/16"
      subnets = {
        odb_space    = "10.12.0.0/24"
        wss_space    = "10.12.1.0/24"
        cogito_space = "10.12.2.0/24"
      }
    }
    hyperspace = {
      space = "10.13.0.0/16"
      subnets = {
        hyperspace_space = "10.13.0.0/24"
      }
    }
    hyperspace_web = {
      space = "10.14.0.0/16"
      subnets = {
        hyperspace_web_space = "10.14.0.0/24"
      }
    }
  }
}

variable "virtual_machine_sets" {
  default = {
    alt = {
      
    }
  }

  type = object({
    alt = optional(map(object({
      vm_count                      = optional(number, 2)
      location                      = string
      resource_group_name           = string
      resource_prefix               = string
      tags                          = optional(map(string), {})
      os_type                       = optional(string, "Windows")
      sku_size                      = string
      disk_controller_type          = optional(string, "SCSI")
      enable_boot_diagnostics       = optional(bool, false)
      capacity_reservation_group_id = optional(string, null)
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
        private_ip_allocation = optional(string, "Dynamic")
        subnet_id             = string
      }))
    })), {})
    primary = optional(map(object({
      vm_count            = optional(number, 2)
      location            = string
      resource_group_name = string
      tags                = optional(map(string), {})
      os_type             = optional(string, "Windows")
      sku_size            = string
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
        private_ip_allocation = optional(string, "Dynamic")
        subnet_id             = string
      }))
    })), {})
  })
}

variable "virtual_machine_set_zone_distribution" {
  type = object({
    alt = map(object({
      custom = optional(map(number), null)
      even   = optional(list(string), null)
    }))
    primary = map(object({
      custom = optional(map(number), null)
      even   = optional(list(string), null)
    }))
  })

  nullable = false
}

variable "cloud_specs_guide" {
  type = object({
    alt = optional(map(object({
      count    = number
      sku_size = string
      data_disks = optional(map(object({
        lun                  = number
        storage_account_type = optional(string, "PremiumV2_LRS")
        disk_size_gb         = number
      })), {})
      os_disk = object({
        storage_account_type = string
        disk_size_gb         = number
      })
    })), {})
    primary = optional(map(object({
      count    = number
      sku_size = string
      data_disks = optional(map(object({
        lun                  = number
        storage_account_type = optional(string, "PremiumV2_LRS")
        disk_size_gb         = number
      })), {})
      os_disk = object({
        storage_account_type = string
        disk_size_gb         = number
      })
    })), {})
  })
}

variable "location_prefixes" {
  type = object({
    southafricanorth   = optional(string, "san")
    eastasia           = optional(string, "eas")
    southeastasia      = optional(string, "sea")
    australiaeast      = optional(string, "aue")
    brazilsouth        = optional(string, "bzs")
    canadacentral      = optional(string, "cac")
    chinanorth3        = optional(string, "cn3")
    northeurope        = optional(string, "neu")
    westeurope         = optional(string, "weu")
    francecentral      = optional(string, "frc")
    germanywestcentral = optional(string, "gwc")
    centralindia       = optional(string, "cin")
    israelcentral      = optional(string, "isc")
    italynorth         = optional(string, "itn")
    japaneast          = optional(string, "jpe")
    koreacentral       = optional(string, "koc")
    norwayeast         = optional(string, "nwe")
    polandcentral      = optional(string, "poc")
    qatarcentral       = optional(string, "qtc")
    swedencentral      = optional(string, "swc")
    switzerlandnorth   = optional(string, "szn")
    uksouth            = optional(string, "uks")
    southcentralus     = optional(string, "scu")
    westus2            = optional(string, "wu2")
    westus3            = optional(string, "wu3")
    centralus          = optional(string, "cus")
    eastus             = optional(string, "eus")
    eastus2            = optional(string, "eu2")
  })

  nullable    = false
  description = "The location prefixes to use for resources."
}
