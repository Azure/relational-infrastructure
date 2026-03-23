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
    image_key_reference               = string
    key_vault_key_reference           = string
    location_key_reference            = string
    resource_group_key_reference      = string
    deploy_scale_set                  = optional(bool, true)
    lock_groups_key_reference         = optional(list(string), [])
    name                              = string
    include_deployment_prefix_in_name = optional(bool, true)
    tags                              = optional(map(string), {})
    extensions_by_key_reference       = optional(list(string), [])
    shutdown_schedule_key_reference   = optional(string, null)
    os_type                           = optional(string, "Windows")
    disk_controller_type              = optional(string, null)
    enable_boot_diagnostics           = optional(bool, false)
    capacity_reservation_group_id     = optional(string, null)
    lock_mode                         = optional(string, null)
    key_vault_resource_id_existing    = optional(string, null)

    data_disk_groups = optional(map(object({
      caching                      = optional(string, "ReadWrite")
      disk_encryption_set_id       = optional(string, null)
      enable_public_network_access = optional(bool, false)
      lock_groups_key_reference    = optional(list(string), [])

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
    })), {})

    network_interfaces = map(object({
      network_key_reference         = string
      subnet_key_reference          = string
      lock_groups_key_reference     = optional(list(string), [])
      private_ip                    = optional(string, null)
      private_ip_allocation         = optional(string, "Dynamic")
      enable_accelerated_networking = optional(bool, true)

      # Load balancer backend pool memberships
      load_balancer_backend_pools = optional(list(object({
        load_balancer_key_reference  = string
        backend_pool_key_reference   = string
      })), [])
    }))

    maintenance = optional(object({
      schedule_key_reference = optional(string, null)
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
    virtual_machines = map(object({
      sequence_number = number
    }))
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

variable "virtual_machine_extensions_automatic_updates_enabled" {
  type        = bool
  default     = false
  description = "Toggles on/off automatic updates for Windows virtual machines."
}

variable "virtual_machine_shutdown_schedules" {
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
  description = "Defines this model's virtual machine shutdown schedules."
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

variable "virtual_machine_system_assigned_identity_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable system-assigned identity for all virtual machines."
}

variable "virtual_machine_user_assigned_identity_resource_ids" {
  type        = list(string)
  default     = []
  description = "A list of user-assigned identity IDs to apply to all virtual machines."
}