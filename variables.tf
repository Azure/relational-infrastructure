variable "deployment_prefix" {
  type        = string
  nullable    = false
  description = "This prefix uniquely identifies the deployment. It is used to prefix all resource names."

  validation {
    condition = (
      length(var.deployment_prefix) > 0 &&
      length(var.deployment_prefix) <= 10 &&
      length(regexall("^[a-zA-Z0-9]+$", var.deployment_prefix)) > 0
    )

    error_message = "The deployment_prefix must contain only letters and digits, and be between 1-10 characters in length."
  }
}

variable "subscription_id" {
  type        = string
  nullable    = false
  description = "The Azure subscription ID to deploy resources into."

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.subscription_id))
    error_message = "The subscription_id must be a valid Azure subscription ID (UUID format)."
  }
}

variable "include_label_tags" {
  type    = bool
  default = false

  description = <<DESCRIPTION
Toggles on/off model resource tags.
These tags can be used to map physical resources deployed in Azure to logical resources defined in this model.
DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of universal tags to apply to all resources defined by this model."
}

variable "lock_groups" {
  type = map(object({
    locked    = bool
    read_only = optional(bool, false)
  }))

  default  = {}
  nullable = false

  description = <<DESCRIPTION
Defines this model's lock groups. 
These groups group Azure resources into logical sets for coordinated lock management during
planned customer maintenance, such as updating a region's infrastructure or a compute tier.
DESCRIPTION
}

variable "default_location_key_reference" {
  type        = string
  nullable    = false
  description = "The default location key reference for resources that don't specify a location."
}

variable "locations" {
  type        = map(string)
  default     = {}
  description = "Defines this model's Azure locations."

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

