variable "virtual_networks" {
  type = map(object({
    location_key_reference           = string
    resource_group_key_reference     = string
    address_space                     = optional(string, null)
    address_spaces                    = optional(set(string), null)
    lock_groups_key_reference         = optional(list(string), [])
    name                              = optional(string, null)
    tags                              = optional(map(string), {})
    peered_to                         = optional(list(string), [])
    dns_ip_addresses                  = optional(set(string), null)
    enable_ddos_protection            = optional(bool, false)
    include_deployment_prefix_in_name = optional(bool, true)

    private_dns_zones = optional(map(object({
      registration_enabled = optional(bool, null)
      resolution_policy    = optional(string, null)
    })), {})

    subnets = map(object({
      address_space                        = string
      name                                 = optional(string, null)
      route_table_key_reference            = optional(string, null)
      network_security_group_key_reference = optional(string, null)
    }))
  }))

  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for network in values(var.virtual_networks) : contains(keys(var.locations), network.location_key_reference)
    ])

    error_message = "All virtual_networks must have a location_key_reference that exists as a key in var.locations."
  }

  validation {
    condition = alltrue([
      for network in values(var.virtual_networks) : contains(keys(var.resource_groups), network.resource_group_key_reference)
    ])

    error_message = "All virtual_networks must have a resource_group_key_reference that exists as a key in var.resource_groups."
  }

  validation {
    condition = alltrue([
      for network in values(var.virtual_networks) : alltrue([
        for lock_group in network.lock_groups_key_reference : contains(keys(var.lock_groups), lock_group)
      ])
    ])

    error_message = "All virtual_networks must have lock_groups_key_reference where every lock_group exists as a key in var.lock_groups."
  }

  validation {
    condition = alltrue([
      for network in values(var.virtual_networks) : alltrue([
        for peer_to_network_key in network.peered_to : (
          contains(keys(var.virtual_networks), peer_to_network_key) ||
          contains(keys(var.external_networks), peer_to_network_key)
        )
      ])
    ])

    error_message = "All virtual_networks must have peered_to networks that exist as keys in var.virtual_networks or var.external_networks."
  }

  validation {
    condition = alltrue([
      for network in values(var.virtual_networks) : alltrue([
        for subnet in values(network.subnets) : (
          subnet.route_table_key_reference == null ||
          contains(keys(var.route_tables), subnet.route_table_key_reference)
        )
      ])
    ])

    error_message = "All subnets must have a route_table_key_reference that exists as a key in var.route_tables or is null."
  }

  validation {
    condition = alltrue([
      for network in values(var.virtual_networks) : alltrue([
        for subnet in values(network.subnets) : (
          subnet.network_security_group_key_reference == null ||
          contains(keys(var.network_security_groups), subnet.network_security_group_key_reference)
        )
      ])
    ])

    error_message = "All subnets must have a network_security_group_key_reference that exists as a key in var.network_security_groups or is null."
  }
}

variable "route_tables" {
  type = map(object({
    location_key_reference       = string
    resource_group_key_reference = string
    lock_groups_key_reference    = optional(list(string), [])
    tags                         = optional(map(string), {})

    routes = map(object({
      destined_for = object({
        address_space = optional(string, null)
        network = optional(object({
          network_key_reference = string
        }), null)
        subnet = optional(object({
          network_key_reference = string
          subnet_key_reference  = string
        }), null)
      })
      route_name  = optional(string, null)
      to_gateway  = optional(bool, false)
      to_internet = optional(bool, false)
      to_nowhere  = optional(bool, false)
      to_appliance = optional(object({
        ip_address = string
      }), null)
    }))
  }))

  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for table in values(var.route_tables) : contains(keys(var.locations), table.location_key_reference)
    ])

    error_message = "All route_tables must have a location_key_reference that exists as a key in var.locations."
  }

  validation {
    condition = alltrue([
      for table in values(var.route_tables) : contains(keys(var.resource_groups), table.resource_group_key_reference)
    ])

    error_message = "All route_tables must have a resource_group_key_reference that exists as a key in var.resource_groups."
  }

  validation {
    condition = alltrue([
      for table in values(var.route_tables) : alltrue([
        for lock_group in table.lock_groups_key_reference : contains(keys(var.lock_groups), lock_group)
      ])
    ])

    error_message = "All route_tables must have lock_groups_key_reference where every lock_group exists as a key in var.lock_groups."
  }
}

variable "network_security_groups" {
  type = map(object({
    location_key_reference       = string
    resource_group_key_reference = string
    lock_groups_key_reference    = optional(list(string), [])
    tags                         = optional(map(string), {})
    security_rules_key_reference = list(string)
  }))

  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for nsg in values(var.network_security_groups) : contains(keys(var.locations), nsg.location_key_reference)
    ])

    error_message = "All network_security_groups must have a location_key_reference that exists as a key in var.locations."
  }

  validation {
    condition = alltrue([
      for nsg in values(var.network_security_groups) : contains(keys(var.resource_groups), nsg.resource_group_key_reference)
    ])

    error_message = "All network_security_groups must have a resource_group_key_reference that exists as a key in var.resource_groups."
  }

  validation {
    condition = alltrue([
      for nsg in values(var.network_security_groups) : alltrue([
        for lock_group in nsg.lock_groups_key_reference : contains(keys(var.lock_groups), lock_group)
      ])
    ])

    error_message = "All network_security_groups must have lock_groups_key_reference where every lock_group exists as a key in var.lock_groups."
  }

  validation {
    condition = alltrue([
      for nsg in values(var.network_security_groups) : alltrue([
        for rule_key in nsg.security_rules_key_reference : contains(keys(var.network_security_rules), rule_key)
      ])
    ])

    error_message = "All network_security_groups must have security_rules_key_reference where every rule exists as a key in var.network_security_rules."
  }
}

variable "network_security_rules" {
  type = map(object({
    protocol   = optional(string, "*")
    port_keys = optional(set(string), null)

    allow = optional(object({
      in = optional(object({
        to = optional(object({
          address_space = optional(string, null)
          network = optional(object({
            name = string
          }), null)
          subnet = optional(object({
            network_key_reference = string
            subnet_key_reference  = string
          }), null)
          vm_set = optional(object({
            name = string
          }), null)
        }), null)
        from = optional(object({
          port_keys    = optional(set(string), null)
          address_space = optional(string, null)
          network = optional(object({
            name = string
          }), null)
          subnet = optional(object({
            network_key_reference = string
            subnet_key_reference  = string
          }), null)
          vm_set = optional(object({
            name = string
          }), null)
        }), null)
      }), null)

      out = optional(object({
        to = optional(object({
          address_space = optional(string, null)
          network = optional(object({
            name = string
          }), null)
          subnet = optional(object({
            network_key_reference = string
            subnet_key_reference  = string
          }), null)
          vm_set = optional(object({
            name = string
          }), null)
        }), null)
        from = optional(object({
          port_keys    = optional(set(string), null)
          address_space = optional(string, null)
          network = optional(object({
            name = string
          }), null)
          subnet = optional(object({
            network_key_reference = string
            subnet_key_reference  = string
          }), null)
          vm_set = optional(object({
            name = string
          }), null)
        }), null)
      }), null)
    }), null)

    deny = optional(object({
      in = optional(object({
        to = optional(object({
          address_space = optional(string, null)
          network = optional(object({
            name = string
          }), null)
          subnet = optional(object({
            network_key_reference = string
            subnet_key_reference  = string
          }), null)
          vm_set = optional(object({
            name = string
          }), null)
        }), null)
        from = optional(object({
          port_keys    = optional(set(string), null)
          address_space = optional(string, null)
          network = optional(object({
            name = string
          }), null)
          subnet = optional(object({
            network_key_reference = string
            subnet_key_reference  = string
          }), null)
          vm_set = optional(object({
            name = string
          }), null)
        }), null)
      }), null)

      out = optional(object({
        to = optional(object({
          address_space = optional(string, null)
          network = optional(object({
            name = string
          }), null)
          subnet = optional(object({
            network_key_reference = string
            subnet_key_reference  = string
          }), null)
          vm_set = optional(object({
            name = string
          }), null)
        }), null)
        from = optional(object({
          port_keys    = optional(set(string), null)
          address_space = optional(string, null)
          network = optional(object({
            name = string
          }), null)
          subnet = optional(object({
            network_key_reference = string
            subnet_key_reference  = string
          }), null)
          vm_set = optional(object({
            name = string
          }), null)
        }), null)
      }), null)
    }), null)
  }))

  default  = {}
  nullable = false
}

variable "network_ports" {
  type        = map(string)
  default     = {}
  nullable    = false
  description = "Defines this model's network ports."
}

variable "external_networks" {
  type = map(object({
    address_space  = optional(string, null)
    address_spaces = optional(set(string), null)

    resource_id = optional(string, null)

    subnets = map(object({
      address_space = string
      name          = optional(string, null)
    }))
  }))

  default     = {}
  nullable    = false
  description = "Defines this model's external networks."
}

