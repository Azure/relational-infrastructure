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
  nullable    = false

  validation {
    condition = contains(
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
    lower(var.primary_location))

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
    condition = contains(
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
    lower(var.alt_location))

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

variable "resource_prefix" {
  type     = string
  nullable = false
}

variable "primary_network_address_spaces" {
  type = object({
    dmz                   = string
    shared_infrastructure = string
    main                  = string
    hyperspace            = string
    hyperspace_web        = string
  })
}

variable "alt_network_address_spaces" {
  type = object({
    dmz                   = string
    shared_infrastructure = string
    main                  = string
    hyperspace            = string
    hyperspace_web        = string
  })
}
