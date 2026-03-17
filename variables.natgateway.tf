variable "nat_gateways" {
  type = map(object({
    location_key_reference       = string
    resource_group_key_reference = string
    lock_groups_key_reference    = optional(list(string), [])
    name                         = optional(string, null)
    tags                         = optional(map(string), {})
    sku_name                     = optional(string, "StandardV2") # Standard or StandardV2
    idle_timeout_in_minutes      = optional(number, 4)
    zones                        = optional(list(string), null) # Ignored for StandardV2 (always zone-redundant)

    # Public IPs to create for this NAT Gateway
    # Uses relational pattern - references public_ip_key_reference from var.public_ip_configurations
    # Note: NAT Gateway does not support DDoS protection on public IPs
    public_ips = optional(map(object({
      public_ip_key_reference = string
      name                    = optional(string, null)
    })), {})

    # Existing public IP resource IDs to associate (IPv4)
    public_ip_resource_ids = optional(set(string), [])

    # Existing public IP resource IDs to associate (IPv6, StandardV2 only)
    public_ip_v6_resource_ids = optional(set(string), [])

    # Existing public IP prefix resource IDs to associate (IPv4)
    public_ip_prefix_resource_ids = optional(set(string), [])

    # Existing public IP prefix resource IDs to associate (IPv6, StandardV2 only)
    public_ip_prefix_v6_resource_ids = optional(set(string), [])
  }))

  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for nat in values(var.nat_gateways) : contains(keys(var.locations), nat.location_key_reference)
    ])

    error_message = "All nat_gateways must have a location_key_reference that exists as a key in var.locations."
  }

  validation {
    condition = alltrue([
      for nat in values(var.nat_gateways) : contains(keys(var.resource_groups), nat.resource_group_key_reference)
    ])

    error_message = "All nat_gateways must have a resource_group_key_reference that exists as a key in var.resource_groups."
  }

  validation {
    condition = alltrue([
      for nat in values(var.nat_gateways) : alltrue([
        for lock_group in nat.lock_groups_key_reference : contains(keys(var.lock_groups), lock_group)
      ])
    ])

    error_message = "All nat_gateways must have lock_groups_key_reference where every lock_group exists as a key in var.lock_groups."
  }

  validation {
    condition = alltrue([
      for nat in values(var.nat_gateways) : contains(["Standard", "StandardV2"], nat.sku_name)
    ])

    error_message = "NAT Gateway sku_name must be 'Standard' or 'StandardV2'."
  }

  validation {
    condition = alltrue([
      for nat in values(var.nat_gateways) : alltrue([
        for pip in values(nat.public_ips) : contains(keys(var.public_ip_configurations), pip.public_ip_key_reference)
      ])
    ])

    error_message = "All nat_gateways.public_ips must have a public_ip_key_reference that exists as a key in var.public_ip_configurations."
  }

  validation {
    condition = alltrue([
      for nat in values(var.nat_gateways) : alltrue([
        for pip in values(nat.public_ips) : (
          # NAT Gateway does not support DDoS protection on public IPs
          var.public_ip_configurations[pip.public_ip_key_reference].ddos_protection_mode == null ||
          var.public_ip_configurations[pip.public_ip_key_reference].ddos_protection_mode == "VirtualNetworkInherited" ||
          var.public_ip_configurations[pip.public_ip_key_reference].ddos_protection_mode == "Disabled"
        )
      ])
    ])

    error_message = "NAT Gateway public IPs do not support DDoS protection. The public_ip_configuration ddos_protection_mode must be null, 'Disabled', or 'VirtualNetworkInherited'."
  }

  validation {
    condition = alltrue([
      for nat in values(var.nat_gateways) : alltrue([
        for pip in values(nat.public_ips) : (
          # NAT Gateway does not support DDoS protection plan association
          var.public_ip_configurations[pip.public_ip_key_reference].ddos_protection_plan_id == null
        )
      ])
    ])

    error_message = "NAT Gateway public IPs do not support DDoS protection plan association. The public_ip_configuration ddos_protection_plan_id must be null."
  }

  validation {
    condition = alltrue([
      for nat in values(var.nat_gateways) : (
        # IPv6 resources only allowed with StandardV2
        nat.sku_name == "StandardV2" ||
        (length(nat.public_ip_v6_resource_ids) == 0 && length(nat.public_ip_prefix_v6_resource_ids) == 0)
      )
    ])

    error_message = "IPv6 public IPs and prefixes are only supported with StandardV2 SKU."
  }

  validation {
    condition = alltrue([
      for nat in values(var.nat_gateways) : alltrue([
        for pip in values(nat.public_ips) : (
          # IPv6 public IPs require StandardV2
          nat.sku_name == "StandardV2" ||
          var.public_ip_configurations[pip.public_ip_key_reference].ip_version != "IPv6"
        )
      ])
    ])

    error_message = "IPv6 public IP configurations are only supported with StandardV2 SKU."
  }
}
