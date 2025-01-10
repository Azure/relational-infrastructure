variable "disk_profiles" {
  type = map(object({
    caching              = optional(string, "ReadWrite")
    storage_account_type = optional(string, "PremiumV2_LRS")
    disk_size_gb         = number
  }))

  nullable = false

  validation {
    condition     = length(keys(var.disk_profiles)) > 0
    error_message = "At least one profile must be defined."
  }
}

variable "virtualmachine_profiles" {
  type = map(object({
    image_reference = object({
      offer     = string
      publisher = string
      sku       = string
      version   = string
    })
    os_disk_profile    = string
    data_disk_profiles = optional(map(string), {})
    os_type            = string
    sku_size           = string
  }))

  nullable = false

  validation {
    condition     = length(keys(var.virtualmachine_profiles)) > 0
    error_message = "At least one (1) [virtualmachine_profile(s)] must be defined."
  }
}

variable "virtualmachine_sets" {
  type = map(object({
    vm_count                   = optional(number, 2)
    location                   = string
    profile_name               = string
    resource_group_name        = string
    tags                       = optional(map(string), {})
    spread_across_zones        = optional(map(number), null)
    spread_evenly_across_zones = optional(list(string), null)
    network_interfaces = map(object({
      private_ip_allocation = optional(string, "Dynamic")
      subnet_id             = string
    }))
  }))

  nullable = false
}
