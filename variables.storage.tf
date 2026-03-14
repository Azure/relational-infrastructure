variable "storage_accounts" {
  type = map(object({
    location_key_reference            = string
    resource_group_key_reference      = string
    name                              = optional(string, null)
    access_tier                       = optional(string, "Hot")
    account_tier                      = optional(string, "Standard")
    account_type                      = optional(string, "StorageV2")
    replication_type                  = optional(string, "ZRS")
    allow_http_access                 = optional(bool, false)
    include_deployment_prefix_in_name = optional(bool, true)
    lock_groups_key_reference         = optional(list(string), [])
    tags                              = optional(map(string), {})

    private_endpoints = optional(map(object({
      name                              = optional(string, null)
      subresource_name                  = string # "blob", "file", "queue", "table", "web", "dfs"
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
  }))

  default     = {}
  nullable    = false
  description = "Defines this model's storage accounts"

  validation {
    condition = alltrue([
      for sa in values(var.storage_accounts) :
      contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], upper(sa.replication_type))
    ])
    error_message = "storage_accounts.*.replication_type must be one of LRS, GRS, RAGRS, ZRS, GZRS, or RAGZRS."
  }

  validation {
    condition = alltrue([
      for sa in values(var.storage_accounts) :
      contains(["Hot", "Cool", "Cold", "Premium"], sa.access_tier)
    ])
    error_message = "storage_accounts.*.access_tier must be one of Hot, Cool, Cold, or Premium."
  }

  validation {
    condition = alltrue([
      for sa in values(var.storage_accounts) :
      contains(["Standard", "Premium"], sa.account_tier)
    ])
    error_message = "storage_accounts.*.account_tier must be Standard or Premium."
  }

  validation {
    condition = alltrue([
      for sa in values(var.storage_accounts) :
      contains(["StorageV2", "BlobStorage", "FileStorage", "BlockBlobStorage"], sa.account_type)
    ])
    error_message = "storage_accounts.*.account_type must be one of StorageV2, BlobStorage, FileStorage, or BlockBlobStorage."
  }

  validation {
    condition = alltrue([
      for sa in values(var.storage_accounts) : alltrue([
        for pe in values(sa.private_endpoints) :
        contains(["blob", "file", "queue", "table", "web", "dfs"], lower(pe.subresource_name))
      ])
    ])
    error_message = "storage_accounts.*.private_endpoints.*.subresource_name must be one of blob, file, queue, table, web, or dfs."
  }

  validation {
    condition = alltrue([
      for sa in values(var.storage_accounts) :
      contains(keys(var.locations), sa.location_key_reference)
    ])
    error_message = "All storage_accounts must have a location_key_reference that exists as a key in var.locations."
  }

  validation {
    condition = alltrue([
      for sa in values(var.storage_accounts) :
      contains(keys(var.resource_groups), sa.resource_group_key_reference)
    ])
    error_message = "All storage_accounts must have a resource_group_key_reference that exists as a key in var.resource_groups."
  }

  validation {
    condition = alltrue([
      for sa in values(var.storage_accounts) : alltrue([
        for lock_group in sa.lock_groups_key_reference :
        contains(keys(var.lock_groups), lock_group)
      ])
    ])
    error_message = "All storage_accounts must have lock_groups_key_reference where every lock_group exists as a key in var.lock_groups."
  }
}

variable "blob_containers" {
  type = map(object({
    storage_account_key_reference = string
    name                          = string
    enable_public_network_access  = optional(bool, false)
  }))

  default     = {}
  nullable    = false
  description = "Defines this model's storage blob containers."

  validation {
    condition = alltrue([
      for container in values(var.blob_containers) :
      contains(keys(var.storage_accounts), container.storage_account_key_reference)
    ])
    error_message = "All blob_containers must have a storage_account_key_reference that exists as a key in var.storage_accounts."
  }

  validation {
    condition = alltrue([
      for container in values(var.blob_containers) :
      !contains(["FileStorage"], var.storage_accounts[container.storage_account_key_reference].account_type)
    ])
    error_message = "blob_containers cannot target FileStorage accounts because FileStorage does not expose the blob service."
  }
}

variable "file_shares" {
  type = map(object({
    storage_account_key_reference = string
    name                          = string
    quota_gb                      = number
    access_tier                   = optional(string, "Hot")
    protocol                      = optional(string, "SMB")
  }))

  default     = {}
  nullable    = false
  description = "Defines this model's storage file shares."

  validation {
    condition = alltrue([
      for share in values(var.file_shares) :
      contains(keys(var.storage_accounts), share.storage_account_key_reference)
    ])
    error_message = "All file_shares must have a storage_account_key_reference that exists as a key in var.storage_accounts."
  }

  validation {
    condition = alltrue([
      for share in values(var.file_shares) :
      contains(["SMB", "NFS"], upper(share.protocol))
    ])
    error_message = "file_shares.*.protocol must be SMB or NFS."
  }

  validation {
    condition = alltrue([
      for share in values(var.file_shares) :
      contains(["Hot", "Cool", "TransactionOptimized", "Premium"], share.access_tier)
    ])
    error_message = "file_shares.*.access_tier must be one of Hot, Cool, TransactionOptimized, or Premium."
  }

  validation {
    condition = alltrue([
      for share in values(var.file_shares) :
      !contains(["BlobStorage", "BlockBlobStorage"], var.storage_accounts[share.storage_account_key_reference].account_type)
    ])
    error_message = "file_shares can only target StorageV2 or FileStorage accounts, not BlobStorage or BlockBlobStorage."
  }

  validation {
    condition = alltrue([
      for share in values(var.file_shares) :
      upper(share.protocol) != "NFS" || var.storage_accounts[share.storage_account_key_reference].account_type == "FileStorage"
    ])
    error_message = "NFS file shares are only supported on FileStorage (Premium) accounts."
  }
}
