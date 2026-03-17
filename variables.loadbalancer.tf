variable "public_ip_configurations" {
  type = map(object({
    allocation_method       = optional(string, "Static")
    ddos_protection_mode    = optional(string, null) # null = auto-determined based on DDoS plan
    ddos_protection_plan_id = optional(string, null)
    domain_name_label       = optional(string, null)
    idle_timeout_in_minutes = optional(number, 4)
    ip_version              = optional(string, "IPv4") # IPv4 or IPv6 (IPv6 requires NAT Gateway StandardV2)
    sku                     = optional(string, "Standard")
    sku_tier                = optional(string, "Regional")
    zones                   = optional(list(string), ["1", "2", "3"])
  }))

  default     = {}
  nullable    = false
  description = "Defines public IP configurations for load balancers and NAT gateways. Load balancers use Standard SKU; NAT Gateway StandardV2 requires StandardV2 SKU public IPs."
}

variable "health_probes" {
  type = map(object({
    protocol            = string                     # Tcp, Http, Https
    port_key            = string                     # References var.network_ports
    request_path        = optional(string, null)     # Required for Http/Https
    interval_in_seconds = optional(number, 5)
    number_of_probes    = optional(number, 2)
    probe_threshold     = optional(number, 1)
  }))

  default     = {}
  nullable    = false
  description = "Defines reusable health probe configurations for load balancer rules."

  validation {
    condition = alltrue([
      for probe in values(var.health_probes) : contains(["Tcp", "Http", "Https"], probe.protocol)
    ])

    error_message = "Health probe protocol must be 'Tcp', 'Http', or 'Https'."
  }

  validation {
    condition = alltrue([
      for probe in values(var.health_probes) : contains(keys(var.network_ports), probe.port_key)
    ])

    error_message = "All health_probes must have a port_key that exists as a key in var.network_ports."
  }

  validation {
    condition = alltrue([
      for probe in values(var.health_probes) : (
        # request_path required for Http/Https protocols
        probe.protocol == "Tcp" || probe.request_path != null
      )
    ])

    error_message = "Health probes using Http or Https protocol must have a request_path specified."
  }
}

variable "load_balancers" {
  type = map(object({
    location_key_reference       = string
    resource_group_key_reference = string
    lock_groups_key_reference    = optional(list(string), [])
    name                         = optional(string, null)
    tags                         = optional(map(string), {})
    sku                          = optional(string, "Standard")
    sku_tier                     = optional(string, "Regional")

    # Load balancer type: internal or external
    # If external and no DDoS plan exists, ddos_protection_mode defaults to "Enabled"
    type = string # "internal" or "external"

    # Frontend configuration
    frontend_ip_configurations = map(object({
      name = optional(string, null)

      # For internal load balancers - subnet reference
      network_key_reference = optional(string, null)
      subnet_key_reference  = optional(string, null)
      private_ip_address    = optional(string, null)
      private_ip_allocation = optional(string, "Dynamic")
      zones                 = optional(list(string), ["1", "2", "3"])

      # For external load balancers - public IP configuration reference
      public_ip_key_reference = optional(string, null)
    }))

    # Backend pools - referenced by VM network_interfaces
    backend_pools = optional(map(object({
      name = optional(string, null)
    })), {})
  }))

  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for lb in values(var.load_balancers) : contains(keys(var.locations), lb.location_key_reference)
    ])

    error_message = "All load_balancers must have a location_key_reference that exists as a key in var.locations."
  }

  validation {
    condition = alltrue([
      for lb in values(var.load_balancers) : contains(keys(var.resource_groups), lb.resource_group_key_reference)
    ])

    error_message = "All load_balancers must have a resource_group_key_reference that exists as a key in var.resource_groups."
  }

  validation {
    condition = alltrue([
      for lb in values(var.load_balancers) : alltrue([
        for lock_group in lb.lock_groups_key_reference : contains(keys(var.lock_groups), lock_group)
      ])
    ])

    error_message = "All load_balancers must have lock_groups_key_reference where every lock_group exists as a key in var.lock_groups."
  }

  validation {
    condition = alltrue([
      for lb in values(var.load_balancers) : contains(["internal", "external"], lb.type)
    ])

    error_message = "All load_balancers must have type set to either 'internal' or 'external'."
  }

  validation {
    condition = alltrue([
      for lb in values(var.load_balancers) : alltrue([
        for fe in values(lb.frontend_ip_configurations) : (
          lb.type == "external"
          ? fe.public_ip_key_reference != null
          : (fe.network_key_reference != null && fe.subnet_key_reference != null)
        )
      ])
    ])

    error_message = "External load balancers require public_ip_key_reference. Internal load balancers require network_key_reference and subnet_key_reference."
  }

  validation {
    condition = alltrue([
      for lb in values(var.load_balancers) : alltrue([
        for fe in values(lb.frontend_ip_configurations) : (
          fe.public_ip_key_reference == null ||
          contains(keys(var.public_ip_configurations), fe.public_ip_key_reference)
        )
      ])
    ])

    error_message = "All frontend_ip_configurations with public_ip_key_reference must reference a key in var.public_ip_configurations."
  }

  validation {
    condition = alltrue([
      for lb in values(var.load_balancers) : alltrue([
        for fe in values(lb.frontend_ip_configurations) : (
          fe.network_key_reference == null ||
          contains(keys(merge(var.virtual_networks, var.external_networks)), fe.network_key_reference)
        )
      ])
    ])

    error_message = "All frontend_ip_configurations with network_key_reference must reference a key in var.virtual_networks or var.external_networks."
  }

  validation {
    condition = alltrue([
      for lb in values(var.load_balancers) : contains(["Standard", "Gateway", "Basic"], lb.sku)
    ])

    error_message = "Load balancer SKU must be 'Standard', 'Gateway', or 'Basic'."
  }
}

variable "load_balancer_rules" {
  type = map(object({
    load_balancer_key_reference = string
    frontend_key_reference      = string
    backend_pool_key_reference  = string
    name                        = optional(string, null)
    protocol                    = optional(string, "Tcp")

    # Port configuration using network_ports reference
    frontend_port_key = string
    backend_port_key  = string

    # Health probe - reference a reusable probe from var.health_probes
    health_probe_key_reference = string

    # Additional rule settings
    enable_floating_ip      = optional(bool, false)
    enable_tcp_reset        = optional(bool, true)
    idle_timeout_in_minutes = optional(number, 4)
    load_distribution       = optional(string, "Default") # Default, SourceIP, SourceIPProtocol
    disable_outbound_snat   = optional(bool, false)
  }))

  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for rule in values(var.load_balancer_rules) : contains(keys(var.load_balancers), rule.load_balancer_key_reference)
    ])

    error_message = "All load_balancer_rules must have a load_balancer_key_reference that exists as a key in var.load_balancers."
  }

  validation {
    condition = alltrue([
      for rule in values(var.load_balancer_rules) :
      contains(keys(var.load_balancers[rule.load_balancer_key_reference].frontend_ip_configurations), rule.frontend_key_reference)
    ])

    error_message = "All load_balancer_rules must have a frontend_key_reference that exists in the referenced load_balancer's frontend_ip_configurations."
  }

  validation {
    condition = alltrue([
      for rule in values(var.load_balancer_rules) :
      contains(keys(var.load_balancers[rule.load_balancer_key_reference].backend_pools), rule.backend_pool_key_reference)
    ])

    error_message = "All load_balancer_rules must have a backend_pool_key_reference that exists in the referenced load_balancer's backend_pools."
  }

  validation {
    condition = alltrue([
      for rule in values(var.load_balancer_rules) : contains(keys(var.network_ports), rule.frontend_port_key)
    ])

    error_message = "All load_balancer_rules must have a frontend_port_key that exists as a key in var.network_ports."
  }

  validation {
    condition = alltrue([
      for rule in values(var.load_balancer_rules) : contains(keys(var.network_ports), rule.backend_port_key)
    ])

    error_message = "All load_balancer_rules must have a backend_port_key that exists as a key in var.network_ports."
  }

  validation {
    condition = alltrue([
      for rule in values(var.load_balancer_rules) : contains(keys(var.health_probes), rule.health_probe_key_reference)
    ])

    error_message = "All load_balancer_rules must have a health_probe_key_reference that exists as a key in var.health_probes."
  }

  validation {
    condition = alltrue([
      for rule in values(var.load_balancer_rules) : contains(["Tcp", "Udp", "All"], rule.protocol)
    ])

    error_message = "Load balancer rule protocol must be 'Tcp', 'Udp', or 'All'."
  }

  validation {
    condition = alltrue([
      for rule in values(var.load_balancer_rules) : contains(["Default", "SourceIP", "SourceIPProtocol"], rule.load_distribution)
    ])

    error_message = "Load balancer rule load_distribution must be 'Default', 'SourceIP', or 'SourceIPProtocol'."
  }
}

variable "load_balancer_nat_rules" {
  type = map(object({
    load_balancer_key_reference = string
    frontend_key_reference      = string
    backend_pool_key_reference  = optional(string, null)
    name                        = optional(string, null)
    protocol                    = optional(string, "Tcp")

    # Port configuration using network_ports reference
    frontend_port_key           = optional(string, null)
    frontend_port_start_key     = optional(string, null)
    frontend_port_end_key       = optional(string, null)
    backend_port_key            = string

    enable_floating_ip          = optional(bool, false)
    enable_tcp_reset            = optional(bool, true)
    idle_timeout_in_minutes     = optional(number, 4)
  }))

  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for rule in values(var.load_balancer_nat_rules) : contains(keys(var.load_balancers), rule.load_balancer_key_reference)
    ])

    error_message = "All load_balancer_nat_rules must have a load_balancer_key_reference that exists as a key in var.load_balancers."
  }

  validation {
    condition = alltrue([
      for rule in values(var.load_balancer_nat_rules) :
      contains(keys(var.load_balancers[rule.load_balancer_key_reference].frontend_ip_configurations), rule.frontend_key_reference)
    ])

    error_message = "All load_balancer_nat_rules must have a frontend_key_reference that exists in the referenced load_balancer's frontend_ip_configurations."
  }

  validation {
    condition = alltrue([
      for rule in values(var.load_balancer_nat_rules) : contains(keys(var.network_ports), rule.backend_port_key)
    ])

    error_message = "All load_balancer_nat_rules must have a backend_port_key that exists as a key in var.network_ports."
  }
}
