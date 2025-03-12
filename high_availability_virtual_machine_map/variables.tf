variable "deployment_prefix" {
  type     = string
  nullable = false
}

variable "ddos_protection_plan_name" {
  type     = string
  nullable = true
}

variable "enable_automatic_updates" {
  type    = bool
  default = false
}

variable "enable_full_network_mesh" {
  type        = bool
  default     = false
  description = "Whether to enable full network mesh for all virtual machines."
}

variable "include_label_tags" {
  type        = bool
  default     = false
  description = "Whether to include label tags."
}

variable "global_tags" {
  type        = map(string)
  default     = {}
  description = "A map of universal tags to apply to all resources."
}

variable "global_extensions" {
  type        = list(string)
  default     = []
  description = "A set of extension names to apply to all virtual machines."
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

  default  = {}
  nullable = false
}

variable "locations" {
  type        = map(string)
  default     = {}
  description = "A map of Azure locations in which resources will be deployed."

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

variable "networks" {
  type = map(object({
    location_name          = string
    address_space          = string
    name                   = optional(string, null)
    peered_to              = optional(list(string), [])
    dns_ip_addresses       = optional(set(string), null)
    enable_ddos_protection = optional(bool, false)

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

      security_rules = optional(map(object({
        name     = optional(string, null)
        priority = number
        protocol = optional(string, "*")

        allow = optional(object({
          in = optional(object({
            from = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
            to = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
          }), null)
          out = optional(object({
            from = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
            to = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
          }), null)
        }), null)

        deny = optional(object({
          in = optional(object({
            from = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
            to = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
          }), null)
          out = optional(object({
            from = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
            to = optional(object({
              address_space = optional(string, null)
              port_range    = optional(string, null)
              network = optional(object({
                network_name = string
              }), null)
              subnet = optional(object({
                network_name = string
                subnet_name  = string
              }), null)
            }), null)
          }), null)
        }), null)
      })), null)
    }))
  }))
}

variable "virtual_machine_sets" {
  type = map(object({
    location_name                 = optional(string, null)
    name                          = optional(string, null)
    resource_group_name           = optional(string, null)
    tags                          = optional(map(string), {})
    extensions                    = optional(list(string), [])
    os_type                       = optional(string, "Windows")
    disk_controller_type          = optional(string, null)
    enable_boot_diagnostics       = optional(bool, false)
    capacity_reservation_group_id = optional(string, null)
    lock_mode                     = optional(string, null)

    image = optional(object({
      id = optional(string, null) # or...
      reference = optional(object({
        offer     = string
        publisher = string
        sku       = string
        version   = string
      }), null)
    }), null)

    data_disks = optional(map(object({
      lun                          = number
      caching                      = optional(string, "ReadWrite")
      enable_public_network_access = optional(bool, false)
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
    })), {})

    network_interfaces = map(object({
      network_name                  = string
      subnet_name                   = string
      private_ip                    = optional(string, null)
      private_ip_allocation         = optional(string, "Dynamic")
      enable_accelerated_networking = optional(bool, true)
    }))
  }))
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
    data_disks = optional(map(object({
      disk_size_gb         = number
      storage_account_type = optional(string, "PremiumV2_LRS")
    })), {})
    os_disk = object({
      disk_size_gb         = number
      storage_account_type = optional(string, "PremiumV2_LRS")
    })
  }))
}


variable "key_vaults" {
  type = map(object({
    location_name = string
    name          = optional(string, null)
    #resource_group_name                = optional(string, null)
    sku_name                        = optional(string, "standard")
    tags                            = optional(map(string), {})
    tenant_id                       = optional(string, null)
    enabled_for_deployment          = optional(bool, false)
    enabled_for_disk_encryption     = optional(bool, false)
    enabled_for_template_deployment = optional(bool, false)
    purge_protection_enabled        = optional(bool, true)
    public_network_access_enabled   = optional(bool, true)
    soft_delete_retention_days      = optional(number, 90)
    legacy_access_policies_enabled  = optional(bool, false)

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




# variable "private_endpoints" {
#   type = map(object({
#       network_name   = string
#       subnet_name    = string
#       key_vault_name = string
#       private_ip     = optional(string, null)
#       name           = optional(string, null)

#     # You can add storage_accounts and other resource types here as needed
#   }))
#   default     = {}
#   description = "Configuration for private endpoints to various Azure resources."
#   nullable    = false
# }

variable "private_endpoints" {
  type = object({
    key_vaults = optional(map(object({
      network_name   = string
      subnet_name    = string
      key_vault_name = string
      private_ip     = optional(string, null)
      name           = optional(string, null)
      dns_zone_group = optional(object({
        name                 = optional(string, "default")
        private_dns_zone_ids = optional(list(string), [])
      }), {})
    })), {})

    storage_accounts = optional(map(object({
      network_name         = string
      subnet_name          = string
      storage_account_name = string
      private_ip           = optional(string, null)
      name                 = optional(string, null)
      subresource_name     = optional(string, "blob") # blob, file, queue, table, etc.
      dns_zone_group = optional(object({
        name                 = optional(string, "default")
        private_dns_zone_ids = optional(list(string), [])
      }), {})
    })), {})

    # Extend this with other Azure services that support private endpoints 
    # such as SQL Server, Cosmos DB, etc.
  })
  default     = { key_vaults = {}, storage_accounts = {} }
  description = "Configuration for private endpoints to various Azure services"
}