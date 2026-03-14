variable "private_dns_zones_create_enabled" {
  type        = bool
  default     = true
  description = "Whether to create private DNS zones. Set to false to only use existing zones via resource_id_existing."
}

variable "private_dns_zones" {
  type = map(object({
    domain_name                  = string
    resource_group_key_reference = optional(string, null)
    resource_id_existing         = optional(string, null)
    registration_enabled         = optional(bool, false)
    resolution_policy            = optional(string, "Default") # "Default" or "NxDomainRedirect"
  }))

  default     = {}
  description = "A map of Azure private DNS zones. Set resource_id_existing to use an existing zone, or resource_group_key_reference to create a new one."
  nullable    = false

  validation {
    condition = alltrue([
      for zone in values(var.private_dns_zones) : contains(["Default", "NxDomainRedirect"], zone.resolution_policy)
    ])

    error_message = "All private_dns_zones must have a resolution_policy of either 'Default' or 'NxDomainRedirect'."
  }

  validation {
    condition = alltrue([
      for zone in values(var.private_dns_zones) :
      zone.resource_id_existing != null || zone.resource_group_key_reference != null
    ])

    error_message = "All private_dns_zones must have either resource_id_existing or resource_group_key_reference set."
  }

  validation {
    condition = alltrue([
      for zone in values(var.private_dns_zones) :
      zone.resource_group_key_reference == null || contains(keys(var.resource_groups), zone.resource_group_key_reference)
    ])

    error_message = "All private_dns_zones with resource_group_key_reference must reference a key that exists in var.resource_groups."
  }
}