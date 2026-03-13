variable "resource_groups" {
  type = map(object({
    name                              = optional(string, null)
    location_key_reference            = optional(string, null)
    lock_groups_key_reference                 = optional(list(string), [])
    tags                              = optional(map(string), {})
    include_deployment_prefix_in_name = optional(bool, true)
  }))

  default     = {}
  nullable    = false
  description = "Defines this model's resource groups."

  validation {
    condition = alltrue([
      for group in values(var.resource_groups) : contains(keys(var.locations), group.location_key_reference)
    ])

    error_message = "All resource groups must have a location_key_reference that exists as a key in var.locations."
  }

  validation {
    condition = alltrue([
      for group in values(var.resource_groups) : alltrue([
        for lock_group in group.lock_groups_key_reference : contains(keys(var.lock_groups), lock_group)
      ])
    ])

    error_message = "All resource groups must have lock_groups where every lock_group exists as a key in var.lock_groups."
  }
}

variable "default_resource_group_key_reference" {
  type        = string
  nullable    = false
  description = "The name of this subscription's default resource group as defined in var.resource_groups."

  validation {
    condition     = contains(keys(var.resource_groups), var.default_resource_group_key_reference)
    error_message = "The default_resource_group_key_reference must exist as a key in var.resource_groups."
  }
}
