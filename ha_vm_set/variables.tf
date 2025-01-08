variable "location" {
  type        = string
  description = <<DESCRIPTION
The Azure region in which resources will be deployed.
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
    lower(var.location))

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
  type        = string
  description = "This naming prefix will be applied to all created resources (e.g., prefix01, prefix02)."
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{3,10}$", var.resource_prefix))
    error_message = "[resource_prefix] must be between 3 and 10 characters in length and contain only alphanumeric characters."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which resources will be deployed."
  nullable    = false
}

variable "resource_tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  nullable    = true
}

variable "virtualmachine_count" {
  type        = number
  description = "The total number of virtual machines to deploy."
  nullable    = false

  validation {
    condition     = var.virtualmachine_count >= 2
    error_message = "[virtualmachine_count] must be 2 or more."
  }
}

variable "virtualmachine_data_disks" {
  type = map(object({
    caching              = optional(string, "ReadWrite")
    storage_account_type = optional(string, "PremiumV2_LRS")
    disk_size_gb         = number
    lun                  = number
  }))

  description = "A map of data disks to attach to each virtual machine."
  nullable    = true

  validation {
    condition = alltrue([for disk in values(var.virtualmachine_data_disks) : contains(
      [
        "none",
        "readonly",
        "readwrite"
      ],
    lower(disk.caching))])

    error_message = <<ERROR_MESSAGE
[virtualmachine_data_disks.caching] must be one of the following values: 

- ReadWrite
- ReadOnly
- None
ERROR_MESSAGE
  }

  validation {
    condition     = alltrue([for disk in values(var.virtualmachine_data_disks) : disk.disk_size_gb >= 0])
    error_message = "[virtualmachine_data_disks.disk_size_gb] must be a positive integer value."
  }

  validation {
    condition     = alltrue([for disk in values(var.virtualmachine_data_disks) : disk.lun >= 0])
    error_message = "[virtualmachine_data_disks.lun] must be greater than or equal to zero (0)."
  }

  validation {
    condition = alltrue([for disk in values(var.virtualmachine_data_disks) : contains(
      [
        "premiumv2_lrs",
        "premium_lrs",
        "premium_zrs",
        "standardssd_lrs",
        "standardssd_zrs",
        "standard_lrs",
        "standard_zrs"
      ],
    lower(disk.storage_account_type))])

    error_message = <<ERROR_MESSAGE
[virtualmachine_data_disks.storage_account_type] must be one of the following values: 

- PremiumV2_LRS
- Premium_LRS
- Premium_ZRS
- StandardSSD_LRS
- StandardSSD_ZRS
- Standard_LRS
- Standard_ZRS
ERROR_MESSAGE
  }
}

variable "virtualmachine_image_reference" {
  type = object({
    offer     = string
    publisher = string
    sku       = string
    version   = string
  })

  description = "The image reference for the virtual machines to deploy."
  nullable    = false
}

variable "virtualmachine_os_type" {
  type        = string
  description = "The base OS type of the virtual machines to deploy."
  nullable    = false

  validation {
    condition = contains(
      [
        "linux",
        "windows"
      ],
      lower(var.virtualmachine_os_type)
    )

    error_message = <<ERROR_MESSAGE
[virtualmachine_os_type] must be one of the following:

- Linux
- Windows
ERROR_MESSAGE
  }
}

variable "virtualmachine_network_interfaces" {
  type = map(object({
    private_ip            = optional(string)
    private_ip_allocation = optional(string, "Dynamic")
    subnet_id             = string
  }))

  description = "A map of network interfaces to create for each virtual machine."
  nullable    = false
}

variable "virtualmachine_os_disk" {
  type = object({
    caching              = optional(string, "ReadWrite")
    storage_account_type = optional(string, "PremiumV2_LRS")
    disk_size_gb         = optional(number, 128)
  })

  description = "The OS disk configuration for the virtual machines to deploy."
  nullable    = false

  validation {
    condition = contains(
      [
        "readwrite",
        "readonly",
        "none"
      ],
    lower(var.virtualmachine_os_disk.caching))

    error_message = <<ERROR_MESSAGE
[virtualmachine_os_disk.caching] must be one of the following values: 

- ReadWrite
- ReadOnly
- None
ERROR_MESSAGE
  }

  validation {
    condition     = var.virtualmachine_os_disk.disk_size_gb >= 0
    error_message = "[virtualmachine_os_disk.disk_size_gb] must be a positive integer value."
  }

  validation {
    condition = contains(
      [
        "premiumv2_lrs",
        "premium_lrs",
        "premium_zrs",
        "standardssd_lrs",
        "standardssd_zrs",
        "standard_lrs",
        "standard_zrs"
      ],
    lower(var.virtualmachine_os_disk.storage_account_type))

    error_message = <<ERROR_MESSAGE
[virtualmachine_os_disk.storage_account_type] must be one of the following values: 

- PremiumV2_LRS
- Premium_LRS
- Premium_ZRS
- StandardSSD_LRS
- StandardSSD_ZRS
- Standard_LRS
- Standard_ZRS
ERROR_MESSAGE
  }
}

variable "virtualmachine_sku_size" {
  type        = string
  description = "The SKU size of the virtual machines to deploy."
  nullable    = false
}

variable "virtualmachine_spread_across_zones" {
  type        = map(number)
  default     = null
  description = <<DESCRIPTION
  A map of availability zones ('1', '2', and/or '3') and the number of virtual machines to deploy in each zone.
  You must configure this variable or the 'virtualmachine_spread_evenly_across_zones' variable, but not both.
  DESCRIPTION
  nullable    = true

  validation {
    condition     = var.virtualmachine_spread_across_zones == null ? true : alltrue([for zone in keys(var.virtualmachine_spread_across_zones) : contains(["1", "2", "3"], zone)])
    error_message = "If provided, [virtualmachine_spread_across_zones] must be a map with keys of one or more of the following values: '1', '2', '3'."
  }

  validation {
    condition     = var.virtualmachine_spread_across_zones == null ? true : length(keys(var.virtualmachine_spread_across_zones)) >= 2
    error_message = "If provided, [virtualmachine_spread_across_zones] must define at least two (2) availability zones."
  }

  validation {
    condition     = var.virtualmachine_spread_across_zones == null ? true : alltrue([for zone in keys(var.virtualmachine_spread_across_zones) : var.virtualmachine_spread_across_zones[zone] > 0])
    error_message = "If provided, [virtualmachine_spread_across_zones] must contain a positive integer value for each availability zone."
  }

  validation {
    condition     = var.virtualmachine_spread_across_zones == null ? true : sum(values(var.virtualmachine_spread_across_zones)) != var.virtualmachine_count
    error_message = "If provided, [virtualmachine_spread_across_zones] virtual machine counts must add up to [virtualmachine_count]."
  }
}

variable "virtualmachine_spread_evenly_across_zones" {
  type        = list(string)
  default     = null
  description = <<DESCRIPTION
  A list of availability zones ('1', '2', and/or '3') that the virtual machines will be spread across evenly.
  You must configure this variable or the 'virtualmachine_spread_across_zones' variable, but not both.
  DESCRIPTION
  nullable    = true

  validation {
    condition     = var.virtualmachine_spread_evenly_across_zones == null ? true : alltrue([for zone in var.virtualmachine_spread_evenly_across_zones : contains(["1", "2", "3"], zone)])
    error_message = "If provided, [virtualmachine_spread_evenly_across_zones] must be a list of two (2) or more of the following values: '1', '2', '3'."
  }

  validation {
    condition     = var.virtualmachine_spread_evenly_across_zones == null ? true : length(var.virtualmachine_spread_evenly_across_zones) >= 2
    error_message = "If provided, [virtualmachine_spread_evenly_across_zones] must define at least two (2) availability zones."
  }
}
