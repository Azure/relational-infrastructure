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
The primary Azure region in which Epic resources will be deployed.
The selected region must have availability zones.

For a complete list of Azure regions, run one of the following commands:

- Powershell: Get-AzLocation | Select-Object Location
- Azure CLI: az account list-locations --query "[].name"

For a complete list of Azure regions with availability zones, see:

https://learn.microsoft.com/azure/reliability/availability-zones-region-support
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
The location must be a valid Azure region with availability zones.

For a complete list of Azure regions, run one of the following commands:

- Powershell: Get-AzLocation | Select-Object Location
- Azure CLI: az account list-locations --query "[].name"

For a complete list of Azure regions with availability zones, see:

https://learn.microsoft.com/azure/reliability/availability-zones-region-support
ERROR_MESSAGE
  }
}

variable "alt_location" {
  type        = string
  description = <<DESCRIPTION
The alternate Azure region in which Epic resources will be deployed.
The selected region must have availability zones.

For a complete list of Azure regions, run one of the following commands:

- Powershell: Get-AzLocation | Select-Object Location
- Azure CLI: az account list-locations --query "[].name"

For a complete list of Azure regions with availability zones, see:

https://learn.microsoft.com/azure/reliability/availability-zones-region-support
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
The location must be a valid Azure region with availability zones.

For a complete list of Azure regions, run one of the following commands:

- Powershell: Get-AzLocation | Select-Object Location
- Azure CLI: az account list-locations --query "[].name"

For a complete list of Azure regions with availability zones, see:

https://learn.microsoft.com/azure/reliability/availability-zones-region-support
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
