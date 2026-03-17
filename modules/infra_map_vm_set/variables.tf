variable "location" {
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

    error_message = <<DESCRIPTION
The Azure location in which resources will be deployed.
The selected location must support availability zones.

The following locations support availability zones:

https://learn.microsoft.com/azure/reliability/availability-zones-region-support

For a complete list of Azure locations:

Azure CLI:        az account list-locations --query "[].name"
Azure Powershell: Get-AzLocation | Select-Object Location
    DESCRIPTION
  }
}

variable "virtual_machine_extensions_automatic_updates_enabled" {
  type        = bool
  default     = true
  description = "Enable automatic updates for virtual machine extensions."
}

variable "user_assigned_identity_ids" {
  type        = list(string)
  description = "A list of user-assigned managed identity resource IDs to assign to the virtual machines."
  default     = []
  nullable    = false
  validation {
    condition     = alltrue([for id in var.user_assigned_identity_ids : startswith(id, "/subscriptions/")])
    error_message = "[user_assigned_identity_ids] must be a list of valid Azure resource IDs."
  }
}

variable "virtual_machine_system_assigned_identity_enabled" {
  type        = bool
  default     = false
  description = "Enable system-assigned managed identity for the virtual machines."
  nullable    = false
}

variable "virtual_machine_extensions" {
  type = map(object({
    name                        = string
    publisher                   = string
    type                        = string
    type_handler_version        = string
    auto_upgrade_minor_version  = optional(bool)
    automatic_upgrade_enabled   = optional(bool)
    deploy_sequence             = optional(number, 3)
    failure_suppression_enabled = optional(bool, false)
    settings                    = optional(string)
    protected_settings          = optional(string)
    provision_after_extensions  = optional(list(string), [])
    tags                        = optional(map(string), null)
    protected_settings_from_key_vault = optional(object({
      secret_url      = string
      source_vault_id = string
    }))
  }))

  default   = {}
  nullable  = false
  sensitive = true
}

variable "resource_prefix" {
  type        = string
  description = "This naming prefix will be applied to all resources."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which resources will be deployed."
  nullable    = false
}

variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group in which resources will be deployed."
  nullable    = false
}

variable "resource_tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  nullable    = true
}

variable "lock_mode" {
  type        = string
  description = "The lock mode to apply to all resources."
  default     = null
  nullable    = true
}

variable "virtual_machines" {
  type = map(object({
    sequence_number = number
  }))
  description = "A map of virtual machines to deploy, keyed by VM name. Each VM has a sequence_number for ordering."
  nullable    = false
}

variable "enable_virtual_machine_boot_diagnostics" {
  type        = bool
  default     = false
  description = "Enable boot diagnostics for the virtual machines."
  nullable    = false
}

variable "virtual_machine_capacity_reservation_group_id" {
  type        = string
  description = "The capacity reservation group ID for the virtual machines."
  nullable    = true
}

variable "enable_os_disk_public_network_access" {
  type        = bool
  default     = false
  description = "Enable public network access for the OS disk."
  nullable    = false
}

variable "virtual_machine_disk_controller_type" {
  type        = string
  description = "The disk controller type for the virtual machines."
  default     = null
  nullable    = true

  validation {
    condition = (var.virtual_machine_disk_controller_type == null || contains(
      [
        "nvme",
        "scsi"
      ],
      lower(var.virtual_machine_disk_controller_type == null ? "" : var.virtual_machine_disk_controller_type))
    )

    error_message = <<ERROR_MESSAGE
    [virtual_machine_disk_controller_type] must be [null] or one of the following:

    - NVMe
    - SCSI

    For more information on NVMe availability, see:

    https://learn.microsoft.com/azure/virtual-machines/nvme-overview
    ERROR_MESSAGE
  }
}

variable "virtual_machine_data_disks" {
  type = map(object({
    image = optional(object({
      copy = optional(object({
        resource_id = string
      }), null)
      import = optional(object({
        uri    = string
        secure = optional(bool, true)
      }), null)
      platform = optional(object({
        image_reference_id = string
      }), null)
      restore = optional(object({
        resource_id = string
      }), null)
    }), null)

    caching                      = optional(string, "ReadWrite")
    enable_public_network_access = optional(bool, false)
    storage_account_type         = optional(string, "PremiumV2_LRS")
    lock_mode                    = optional(string, null)
    tags                         = optional(map(string), {})
    disk_size_gb                 = number
    lun                          = number
  }))

  default     = {}
  description = "A map of data disks to attach to each virtual machine."
  nullable    = true

  validation {
    condition = alltrue([for disk in values(var.virtual_machine_data_disks) : contains(
      [
        "none",
        "readonly",
        "readwrite"
      ],
    lower(disk.caching))])

    error_message = <<ERROR_MESSAGE
    [virtual_machine_data_disks.caching] must be one of the following values: 

    - ReadWrite
    - ReadOnly
    - None
    ERROR_MESSAGE
  }

  validation {
    condition     = alltrue([for disk in values(var.virtual_machine_data_disks) : disk.disk_size_gb >= 0])
    error_message = "[virtual_machine_data_disks.disk_size_gb] must be a positive integer value."
  }

  validation {
    condition     = alltrue([for disk in values(var.virtual_machine_data_disks) : disk.lun >= 0])
    error_message = "[virtual_machine_data_disks.lun] must be greater than or equal to zero (0)."
  }

  validation {
    condition = alltrue([for disk in values(var.virtual_machine_data_disks) : contains(
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

variable "virtual_machine_image" {
  type = object({
    id = optional(string, null)
    reference = optional(object({
      offer     = string
      publisher = string
      sku       = string
      version   = string
    }), null)
  })

  description = "The image for the virtual machines to deploy."
  nullable    = false

  validation {
    condition     = (var.virtual_machine_image.id != null) != (var.virtual_machine_image.reference != null)
    error_message = "You must provide either an [id] or a [reference] for the virtual machine image, but not both."
  }
}

variable "virtual_machine_shutdown_schedule" {
  type = map(object({
    daily_recurrence_time = string
    notification_settings = optional(object({
      enabled         = optional(bool, false)
      email           = optional(string, null)
      time_in_minutes = optional(string, "30")
      webhook_url     = optional(string, null)
    }), { enabled = false })
    timezone = string
    enabled  = optional(bool, true)
    tags     = optional(map(string), null)
  }))

  default     = {}
  nullable    = false
  description = "A map of shutdown schedules to create for each virtual machine."
}

variable "virtual_machine_network_interfaces" {
  type = map(object({
    private_ip                    = optional(string)
    enable_accelerated_networking = optional(bool, true)
    lock_mode                     = optional(string, null)
    subnet_id                     = string

    # Load balancer backend pool resource IDs
    load_balancer_backend_pool_resource_ids = optional(list(string), [])
  }))

  description = "A map of network interfaces to create for each virtual machine."
  nullable    = false
}

variable "virtual_machine_os_disk" {
  type = object({
    caching              = optional(string, "ReadWrite")
    storage_account_type = optional(string, "PremiumV2_LRS")
    disk_size_gb         = optional(number, 128)
    lock_mode            = optional(string, null)
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
    lower(var.virtual_machine_os_disk.caching))

    error_message = <<ERROR_MESSAGE
[virtual_machine_os_disk.caching] must be one of the following: 

- ReadWrite
- ReadOnly
- None
ERROR_MESSAGE
  }

  validation {
    condition     = var.virtual_machine_os_disk.disk_size_gb >= 0
    error_message = "[virtual_machine_os_disk.disk_size_gb] must be a positive integer value."
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
    lower(var.virtual_machine_os_disk.storage_account_type))

    error_message = <<ERROR_MESSAGE
[virtual_machine_os_disk.storage_account_type] must be one of the following values: 

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

variable "virtual_machine_os_type" {
  type        = string
  description = "The base OS type of the virtual machines to deploy."
  nullable    = false

  validation {
    condition = contains(
      [
        "linux",
        "windows"
      ],
      lower(var.virtual_machine_os_type)
    )

    error_message = <<ERROR_MESSAGE
[virtual_machine_os_type] must be one of the following:

- Linux
- Windows
ERROR_MESSAGE
  }
}

variable "maintenance_configuration" {
  type = object({
    schedule = object({
      duration        = string
      recur_every     = string
      start_date_time = string
      time_zone       = string
    })

    scope         = string
    schedule_name = string
  })

  default     = null
  nullable    = true
  description = "The maintenance configuration for the virtual machines to deploy."
}

variable "deploy_scale_set" {
  type        = bool
  default     = true
  description = "Whether to deploy the virtual machines in a scale set."
  nullable    = false
}

variable "virtual_machine_sku_size" {
  type        = string
  description = "The SKU size of the virtual machines to deploy."
  nullable    = false
}

variable "virtual_machine_zone_distribution" {
  type = object({
    custom = optional(map(number), null)
    even   = optional(list(string), null)
  })

  description = "The virtual machine zone distribution strategy (either custom or even)."
  nullable    = true

  validation {
    condition     = (try(var.virtual_machine_zone_distribution.custom, null) == null) != (try(var.virtual_machine_zone_distribution.even, null) == null)
    error_message = "You must configure either the 'custom' or 'even' zone distribution strategy, but not both."
  }

  validation {
    condition     = try(var.virtual_machine_zone_distribution.custom, null) == null ? true : ((length(distinct(keys(var.virtual_machine_zone_distribution.custom))) >= 2) && (alltrue([for zone in keys(var.virtual_machine_zone_distribution.custom) : contains(["1", "2", "3"], zone)])))
    error_message = "If provided, [virtual_machine_zone_distribution.custom] must be a map with keys of at least two (2) of the following availability zones: '1', '2', '3'."
  }

  validation {
    condition     = try(var.virtual_machine_zone_distribution.custom, null) == null ? true : (length(distinct(keys(var.virtual_machine_zone_distribution.custom))) == length(keys(var.virtual_machine_zone_distribution.custom)))
    error_message = "If provided, [virtual_machine_zone_distribution.custom] must not contain duplicate availability zones."
  }

  validation {
    condition     = try(var.virtual_machine_zone_distribution.custom, null) == null ? true : (sum(values(var.virtual_machine_zone_distribution.custom)) == length(var.virtual_machines))
    error_message = "If provided, [virtual_machine_zone_distribution.custom] virtual machine counts must add up to the number of virtual machines."
  }

  validation {
    condition     = try(var.virtual_machine_zone_distribution.even, null) == null ? true : ((length(distinct(var.virtual_machine_zone_distribution.even)) >= 1) && (alltrue([for zone in var.virtual_machine_zone_distribution.even : contains(["1", "2", "3"], zone)])))
    error_message = "If provided, [virtual_machine_zone_distribution.even] must be a list of at least one (1) of the following availability zones: '1', '2', '3'."
  }

  validation {
    condition     = try(var.virtual_machine_zone_distribution.even, null) == null ? true : ((length(distinct(var.virtual_machine_zone_distribution.even)) == length(var.virtual_machine_zone_distribution.even)))
    error_message = "If provided, [virtual_machine_zone_distribution.even] must not contain duplicate availability zones."
  }
}


variable "key_vault_configuration" {
  type = object({
    resource_id = string
    secret_configuration = optional(object({
      name                           = optional(string, null)
      expiration_date_length_in_days = optional(number, 45)
      content_type                   = optional(string, "text/plain")
      not_before_date                = optional(string, null)
      tags                           = optional(map(string), {})
    }), {})
  })
  default     = null
  description = <<DESCRIPTION
Configuration for storing auto-generated admin credentials in Key Vault.

- `resource_id` - (Required) - The resource ID of the Key Vault to store generated secrets.
- `secret_configuration` - (Optional) - Configuration for the Key Vault secret:
  - `name` - (Optional) - The name to use for the key vault secret that stores the auto-generated ssh key or password.
  - `expiration_date_length_in_days` - (Optional) - Days from installation to set expiration. Defaults to `45`.
  - `content_type` - (Optional) - The secret content type. Defaults to `text/plain`.
  - `not_before_date` - (Optional) - UTC datetime (Y-m-d'T'H:M:S'Z) before which this key is not valid.
  - `tags` - (Optional) - Tags to assign to this secret resource.
DESCRIPTION
}
