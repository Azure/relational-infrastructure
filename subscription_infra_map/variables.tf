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

variable "enable_automatic_updates" {
  type        = bool
  default     = false
  description = "Toggles on/off automatic updates for Windows virtual machines."
}

variable "include_label_tags" {
  type    = bool
  default = false

  description = <<DESCRIPTION
Toggles on/off model resource tags.
These tags can be used to map physical resources deployed in Azure to logical resources defined in this model.
DESCRIPTION
}

variable "default_resource_group_name" {
  type        = string
  nullable    = false
  description = "The name of this subscription's default resource group as defined in var.resource_groups."

  validation {
    condition     = contains(keys(var.resource_groups), var.default_resource_group_name)
    error_message = "The default_resource_group_name must exist as a key in var.resource_groups."
  }
}

variable "private_link_resource_group_name" {
  type     = string
  default  = null
  nullable = true

  description = <<DESCRIPTION
The name of this subscription's shared private link resource group as defined in var.resource_groups.
If not provided, var.default_resource_group_name will be used.
DESCRIPTION

  validation {
    condition = (
      var.private_link_resource_group_name == null ||
      try(contains(keys(var.resource_groups), var.private_link_resource_group_name), false)
    )

    error_message = "If provided, the private_link_resource_group_name must exist as a key in var.resource_groups."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of universal tags to apply to all resources defined by this model."
}

variable "network_ports" {
  type        = map(string)
  default     = {}
  nullable    = false
  description = "Defines this model's network ports."
}

variable "extensions" {
  type        = list(string)
  default     = []
  description = <<DESCRIPTION
A list of extension names (as defined in var.virtual_machine_extensions) to apply to all 
virtual machines deployed by this model.
DESCRIPTION

  validation {
    condition = alltrue([
      for ext in var.extensions : contains(keys(var.virtual_machine_extensions), ext)
    ])

    error_message = "All extensions must exist as keys in var.virtual_machine_extensions."
  }
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

variable "maintenance_schedules" {
  type = map(object({
    repeat_every = object({
      # One and only one of these properties may be set at the same time.
      day    = optional(bool, false)  # once a day (days == 1)
      week   = optional(bool, false)  # once a week (weeks == 1)
      month  = optional(bool, false)  # once a month (months == 1)
      days   = optional(number, null) # once every n days
      weeks  = optional(number, null) # once every n weeks
      months = optional(number, null) # once every n months
    })

    start_date_time_utc      = string
    expiration_date_time_utc = optional(string, null)
    duration                 = optional(string, "1:30")
  }))

  default     = {}
  nullable    = false
  description = "Defines this model's VM set maintenance schedules."
}

variable "resource_groups" {
  type = map(object({
    name                              = optional(string, null)
    location_name                     = optional(string, null)
    lock_groups                       = optional(list(string), [])
    tags                              = optional(map(string), {})
    include_deployment_prefix_in_name = optional(bool, true)
  }))

  default     = {}
  nullable    = false
  description = "Defines this model's resource groups."

  validation {
    condition = alltrue([
      for group in values(var.resource_groups) : contains(keys(var.locations), group.location_name)
    ])

    error_message = "All resource groups must have a location_name that exists as a key in var.locations."
  }

  validation {
    condition = alltrue([
      for group in values(var.resource_groups) : alltrue([
        for lock_group in group.lock_groups : contains(keys(var.lock_groups), lock_group)
      ])
    ])

    error_message = "All resource groups must have lock_groups where every lock_group exists as a key in var.lock_groups."
  }
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

  default     = {}
  nullable    = false
  description = "Defines this model's virtual machine extensions."
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

variable "network_security_rules" {
  type = map(object({
    protocol   = optional(string, "*")
    port_names = optional(set(string), null)

    allow = optional(object({
      in = optional(object({
        to = optional(object({
          address_space = optional(string, null)
          network = optional(object({
            name = string
          }), null)
          subnet = optional(object({
            network_name = string
            subnet_name  = string
          }), null)
          vm_set = optional(object({
            name = string
          }), null)
        }), null)
        from = optional(object({
          port_names    = optional(set(string), null)
          address_space = optional(string, null)
          network = optional(object({
            name = string
          }), null)
          subnet = optional(object({
            network_name = string
            subnet_name  = string
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
            network_name = string
            subnet_name  = string
          }), null)
          vm_set = optional(object({
            name = string
          }), null)
        }), null)
        from = optional(object({
          port_names    = optional(set(string), null)
          address_space = optional(string, null)
          network = optional(object({
            name = string
          }), null)
          subnet = optional(object({
            network_name = string
            subnet_name  = string
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
            network_name = string
            subnet_name  = string
          }), null)
          vm_set = optional(object({
            name = string
          }), null)
        }), null)
        from = optional(object({
          port_names    = optional(set(string), null)
          address_space = optional(string, null)
          network = optional(object({
            name = string
          }), null)
          subnet = optional(object({
            network_name = string
            subnet_name  = string
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
            network_name = string
            subnet_name  = string
          }), null)
          vm_set = optional(object({
            name = string
          }), null)
        }), null)
        from = optional(object({
          port_names    = optional(set(string), null)
          address_space = optional(string, null)
          network = optional(object({
            name = string
          }), null)
          subnet = optional(object({
            network_name = string
            subnet_name  = string
          }), null)
          vm_set = optional(object({
            name = string
          }), null)
        }), null)
      }), null)
    }), null)
  }))
}

variable "networks" {
  type = map(object({
    location_name                     = string
    resource_group_name               = string
    address_space                     = optional(string, null)
    address_spaces                    = optional(set(string), null)
    lock_groups                       = optional(list(string), [])
    name                              = optional(string, null)
    tags                              = optional(map(string), {})
    peered_to                         = optional(list(string), [])
    dns_ip_addresses                  = optional(set(string), null)
    enable_ddos_protection            = optional(bool, false)
    include_deployment_prefix_in_name = optional(bool, true)

    private_dns_zones = optional(object({
      registration_zone_name = optional(string, null)
      resolution_zone_name   = optional(string, null)
      resolution_zone_names  = optional(list(string), null)
    }), null)

    subnets = map(object({
      address_space       = string
      name                = optional(string, null)
      route_table_name    = optional(string, null)
      security_group_name = optional(string, null)
      lock_mode           = optional(string, null)

      route_traffic = optional(map(object({
        destined_for = object({
          address_space = optional(string, null)
          network = optional(object({
            network_name = string
          }), null)
          subnet = optional(object({
            network_name = string
            subnet_name  = string
          }), null)
        })
        route_name  = optional(string, null)
        to_gateway  = optional(bool, false)
        to_internet = optional(bool, false)
        to_nowhere  = optional(bool, false)
        to_appliance = optional(object({
          ip_address = string
        }), null)
      })), null)

      security_rules = optional(list(string), [])
    }))
  }))

  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for network in values(var.networks) : contains(keys(var.locations), network.location_name)
    ])

    error_message = "All networks must have a location_name that exists as a key in var.locations."
  }

  validation {
    condition = alltrue([
      for network in values(var.networks) : contains(keys(var.resource_groups), network.resource_group_name)
    ])

    error_message = "All networks must have a resource_group_name that exists as a key in var.resource_groups."
  }

  validation {
    condition = alltrue([
      for network in values(var.networks) : alltrue([
        for lock_group in network.lock_groups : contains(keys(var.lock_groups), lock_group)
      ])
    ])

    error_message = "All networks must have lock_groups where every lock_group exists as a key in var.lock_groups."
  }

  validation {
    condition = alltrue([
      for network in values(var.networks) : alltrue([
        for peer_to_network_name in network.peered_to : (
          contains(keys(var.networks), peer_to_network_name) ||
          contains(keys(var.external_networks), peer_to_network_name)
        )
      ])
    ])

    error_message = "All networks must have peered_to networks that exist as keys in var.networks or var.external_networks."
  }
}

variable "private_dns_zones" {
  type = map(object({
    domain_name         = string
    resource_group_name = string
  }))

  default     = {}
  description = "A map of Azure private DNS zones to be deployed."
  nullable    = false
}

variable "virtual_machine_images" {
  type = map(object({
    id = optional(string, null)
    reference = optional(object({
      offer     = string
      publisher = string
      sku       = string
      version   = string
    }), null)
  }))

  default     = {}
  nullable    = false
  description = "Defines this model's virtual machine images"
}

variable "virtual_machine_sets" {
  type = map(object({
    image_name                        = string
    key_vault_name                    = string
    location_name                     = string
    resource_group_name               = string
    subscription_name                 = string
    deploy_scale_set                  = optional(bool, true)
    lock_groups                       = optional(list(string), [])
    name                              = string
    include_deployment_prefix_in_name = optional(bool, true)
    tags                              = optional(map(string), {})
    extensions                        = optional(list(string), [])
    os_type                           = optional(string, "Windows")
    disk_controller_type              = optional(string, null)
    enable_boot_diagnostics           = optional(bool, false)
    capacity_reservation_group_id     = optional(string, null)
    lock_mode                         = optional(string, null)
    secrets_key_vault_resource_id     = optional(string, null)

    data_disk_groups = optional(map(object({
      caching                      = optional(string, "ReadWrite")
      disk_encryption_set_id       = optional(string, null)
      enable_public_network_access = optional(bool, false)
      lock_groups                  = optional(list(string), [])

      image = optional(object({
        copy = optional(object({
          resource_id = string
        }), null) # or...
        import = optional(object({
          uri    = string
          secure = optional(bool, true)
        }), null) # or...
        platform = optional(object({
          image_reference_id = string
        }), null) # or...
        restore = optional(object({
          resource_id = string
        }), null)
      }), null)
    })))

    network_interfaces = map(object({
      network_name                  = string
      subnet_name                   = string
      lock_groups                   = optional(list(string), [])
      private_ip                    = optional(string, null)
      private_ip_allocation         = optional(string, "Dynamic")
      enable_accelerated_networking = optional(bool, true)
    }))

    maintenance = optional(object({
      schedule_name = optional(string, null)
    }), {})
  }))

  default  = {}
  nullable = false
}

variable "virtual_machine_set_zone_distribution" {
  type = map(object({
    custom = optional(map(number), null)
    even   = optional(list(string), null)
  }))

  default     = {}
  description = "The availability zone distribution configurations for [virtual_machine_sets]."
  nullable    = false
}

variable "virtual_machine_set_specs" {
  type = map(object({
    vm_count = optional(number, 2)
    sku_size = string

    data_disk_groups = optional(map(object({
      disk_count           = optional(number, 1)
      disk_iops_read_only  = optional(number, null)
      disk_iops_read_write = optional(number, null)
      disk_size_gb         = number
      storage_account_type = optional(string, "PremiumV2_LRS")
    })), {})

    os_disk = object({
      disk_size_gb         = number
      storage_account_type = optional(string, "PremiumV2_LRS")
    })
  }))

  default  = {}
  nullable = false
}

variable "storage_accounts" {
  type = map(object({
    location_name                     = string
    resource_group_name               = string
    name                              = optional(string, null)
    access_tier                       = optional(string, "Hot")
    account_tier                      = optional(string, "Standard")
    account_type                      = optional(string, "StorageV2")
    replication_type                  = optional(string, "ZRS")
    allow_http_access                 = optional(bool, false)
    include_deployment_prefix_in_name = optional(bool, true)
    lock_groups                       = optional(list(string), [])
    tags                              = optional(map(string), {})
  }))

  default     = {}
  nullable    = false
  description = "Defines this model's storage accounts"
}

variable "blob_containers" {
  type = map(object({
    storage_account_name         = string
    name                         = string
    enable_public_network_access = optional(bool, false)
  }))

  default     = {}
  nullable    = false
  description = "Defines this model's storage blob containers."
}

variable "file_shares" {
  type = map(object({
    storage_account_name = string
    name                 = string
    quota_gb             = number
    access_tier          = optional(string, "Hot")
    protocol             = optional(string, "SMB")
  }))

  default     = {}
  nullable    = false
  description = "Defines this model's storage file shares."
}

variable "key_vaults" {
  type = map(object({
    location_name                     = string
    name                              = optional(string, null)
    resource_group_name               = string
    lock_groups                       = optional(list(string), [])
    include_deployment_prefix_in_name = optional(bool, true)
    sku_name                          = optional(string, "standard")
    tags                              = optional(map(string), {})
    tenant_id                         = optional(string, null)
    enabled_for_deployment            = optional(bool, false)
    enabled_for_disk_encryption       = optional(bool, false)
    enabled_for_template_deployment   = optional(bool, false)
    purge_protection_enabled          = optional(bool, true)
    public_network_access_enabled     = optional(bool, true)
    soft_delete_retention_days        = optional(number, 90)
    legacy_access_policies_enabled    = optional(bool, false)

    network_acls = optional(object({
      bypass                     = optional(string, "AzureServices")
      default_action             = optional(string, "Deny")
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }), {})

    contacts = optional(map(object({
      email = string
      name  = optional(string, null)
      phone = optional(string, null)
    })), {})

    secrets = optional(map(object({
      name            = string
      content_type    = optional(string, null)
      tags            = optional(map(any), null)
      not_before_date = optional(string, null)
      expiration_date = optional(string, null)
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        description                            = optional(string, null)
        skip_service_principal_aad_check       = optional(bool, false)
        condition                              = optional(string, null)
        condition_version                      = optional(string, null)
        delegated_managed_identity_resource_id = optional(string, null)
        principal_type                         = optional(string, null)
      })), {})
    })), {})

    secrets_value = optional(map(string), null)

    keys = optional(map(object({
      name            = string
      key_type        = string
      key_opts        = optional(list(string), ["sign", "verify"])
      key_size        = optional(number, null)
      curve           = optional(string, null)
      not_before_date = optional(string, null)
      expiration_date = optional(string, null)
      tags            = optional(map(any), null)
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        description                            = optional(string, null)
        skip_service_principal_aad_check       = optional(bool, false)
        condition                              = optional(string, null)
        condition_version                      = optional(string, null)
        delegated_managed_identity_resource_id = optional(string, null)
        principal_type                         = optional(string, null)
      })), {})
      rotation_policy = optional(object({
        automatic = optional(object({
          time_after_creation = optional(string, null)
          time_before_expiry  = optional(string, null)
        }), null)
        expire_after         = optional(string, null)
        notify_before_expiry = optional(string, null)
      }), null)
    })), {})

    legacy_access_policies = optional(map(object({
      object_id               = string
      application_id          = optional(string, null)
      certificate_permissions = optional(set(string), [])
      key_permissions         = optional(set(string), [])
      secret_permissions      = optional(set(string), [])
      storage_permissions     = optional(set(string), [])
    })), {})

    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})

    private_endpoints = optional(map(object({
      name = optional(string, null)
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        description                            = optional(string, null)
        skip_service_principal_aad_check       = optional(bool, false)
        condition                              = optional(string, null)
        condition_version                      = optional(string, null)
        delegated_managed_identity_resource_id = optional(string, null)
        principal_type                         = optional(string, null)
      })), {})
      lock = optional(object({
        kind = string
        name = optional(string, null)
      }), null)
      tags                                    = optional(map(string), null)
      subnet_resource_id                      = string
      private_dns_zone_group_name             = optional(string, "default")
      private_dns_zone_resource_ids           = optional(set(string), [])
      application_security_group_associations = optional(map(string), {})
      private_service_connection_name         = optional(string, null)
      network_interface_name                  = optional(string, null)
      location                                = optional(string, null)
      resource_group_name                     = optional(string, null)
      ip_configurations = optional(map(object({
        name               = string
        private_ip_address = string
      })), {})
    })), {})

    private_endpoints_manage_dns_zone_group = optional(bool, true)

    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)

    diagnostic_settings = optional(map(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string, null)
      storage_account_resource_id              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    })), {})

    wait_for_rbac_before_key_operations = optional(object({
      create  = optional(string, "30s")
      destroy = optional(string, "0s")
    }), {})

    wait_for_rbac_before_secret_operations = optional(object({
      create  = optional(string, "30s")
      destroy = optional(string, "0s")
    }), {})

    wait_for_rbac_before_contact_operations = optional(object({
      create  = optional(string, "30s")
      destroy = optional(string, "0s")
    }), {})
  }))

  default     = {}
  description = "A map of Azure Key Vaults to be deployed."
  nullable    = false
}


# Define the private endpoints configuration
variable "private_endpoints" {
  type = object({
    key_vaults = optional(map(object({
      network_name                      = string
      subnet_name                       = string
      key_vault_name                    = string
      resource_group_name               = string
      lock_groups                       = optional(list(string), [])
      private_ip                        = optional(string, null)
      name                              = optional(string, null)
      include_deployment_prefix_in_name = optional(bool, true)
      dns_zone_group = optional(object({
        name                   = optional(string, "default")
        private_dns_zone_id    = optional(string, null)
        private_dns_zone_ids   = optional(set(string), [])
        private_dns_zone_name  = optional(string, null)
        private_dns_zone_names = optional(list(string), [])
      }), {})
    })), {})

    blob_containers = optional(map(object({
      container_name                    = string
      network_name                      = string
      subnet_name                       = string
      resource_group_name               = string
      lock_groups                       = optional(list(string), [])
      private_ip                        = optional(string, null)
      name                              = optional(string, null)
      include_deployment_prefix_in_name = optional(bool, true)

      dns_zone_group = optional(object({
        name                   = optional(string, "default")
        private_dns_zone_id    = optional(string, null)
        private_dns_zone_ids   = optional(set(string), [])
        private_dns_zone_name  = optional(string, null)
        private_dns_zone_names = optional(list(string), [])
      }), {})
    })), {})

    file_shares = optional(map(object({
      share_name                        = string
      network_name                      = string
      subnet_name                       = string
      resource_group_name               = string
      lock_groups                       = optional(list(string), [])
      private_ip                        = optional(string, null)
      name                              = optional(string, null)
      include_deployment_prefix_in_name = optional(bool, true)

      dns_zone_group = optional(object({
        name                   = optional(string, "default")
        private_dns_zone_id    = optional(string, null)
        private_dns_zone_ids   = optional(set(string), [])
        private_dns_zone_name  = optional(string, null)
        private_dns_zone_names = optional(list(string), [])
      }), {})
    })), {})
  })

  default     = { key_vaults = {}, blob_containers = {}, file_shares = {} }
  description = "Configuration for private endpoints to various Azure services"
  nullable    = false
}
