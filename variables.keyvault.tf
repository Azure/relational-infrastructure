variable "default_key_vault_admin_role_definition_id_or_name" {
  type        = string
  default     = "Key Vault Administrator"
  description = "The role definition ID or name to use for default Key Vault administrator role assignments."
}

variable "key_vaults" {
  type = map(object({
    location_key_reference           = string
    name                              = optional(string, null)
    resource_group_key_reference     = string
    lock_groups_key_reference                 = optional(list(string), [])
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
      name                              = optional(string, null)
      network_key_reference             = string
      subnet_key_reference              = string
      resource_group_key_reference      = optional(string, null)
      lock_groups_key_reference         = optional(list(string), [])
      private_ip                        = optional(string, null)
      include_deployment_prefix_in_name = optional(bool, true)
      tags                              = optional(map(string), null)
      private_dns_zone_group_name       = optional(string, "default")
      private_dns_zone_key_references   = optional(list(string), [])
      private_dns_zone_resource_ids     = optional(set(string), [])
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
