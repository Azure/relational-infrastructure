locals {
  # Storage accounts to provision with all computed values
  storage_accounts_to_provision = {
    for sa_key, sa in var.storage_accounts : sa_key => {
      name                       = local.storage_account_names[sa_key]
      location                   = var.locations[sa.location_key_reference]
      resource_group_name        = module.resource_groups[sa.resource_group_key_reference].name
      tags                       = local.storage_account_tags[sa_key]
      access_tier                = sa.access_tier
      account_tier               = sa.account_tier
      account_kind               = sa.account_type
      account_replication_type   = sa.replication_type
      https_traffic_only_enabled = !(sa.allow_http_access)

      lock = (
        length([
          for group in sa.lock_groups_key_reference :
          group if contains(keys(local.locked_groups), group)
        ]) > 0
        ? (
          anytrue([
            for group in sa.lock_groups_key_reference :
            contains(keys(local.locked_groups), group)
            && try(local.locked_groups[group].read_only, false)
          ])
          ? { kind = local.lock_modes.read_only }
          : { kind = local.lock_modes.no_delete }
        )
        : null
      )

      containers = {
        for container_key, container in var.blob_containers :
        container_key => {
          name = container.name
          public_access = container.enable_public_network_access ? "Blob" : "None"
        } if container.storage_account_key_reference == sa_key
      }

      shares = {
        for share_key, share in var.file_shares :
        share_key => {
          name             = share.name
          quota            = share.quota_gb
          access_tier      = share.access_tier
          enabled_protocol = share.protocol
        } if share.storage_account_key_reference == sa_key
      }

      private_endpoints = local.storage_account_private_endpoints[sa_key]
    }
  }

  # Transform Storage Account private endpoints from key references to AVM module format
  storage_account_private_endpoints = {
    for sa_key, sa in var.storage_accounts : sa_key => {
      for pe_key, pe in sa.private_endpoints : pe_key => {
        name = coalesce(
          pe.name,
          pe.include_deployment_prefix_in_name
          ? "${var.deployment_prefix}-${sa_key}-${pe.subresource_name}-pe"
          : "${sa_key}-${pe.subresource_name}-pe"
        )

        subresource_name  = pe.subresource_name
        subnet_resource_id = local.network_resource_ids[pe.network_key_reference].subnets[pe.subnet_key_reference].resource_id

        private_dns_zone_group_name = pe.private_dns_zone_group_name

        private_dns_zone_resource_ids = concat(
          tolist(pe.private_dns_zone_resource_ids),
          [
            for zone_key in pe.private_dns_zone_key_references :
            local.private_dns_zone_resource_ids[zone_key]
          ]
        )

        private_service_connection_name = "${coalesce(pe.name, "${sa_key}-${pe.subresource_name}-pe")}-psc"
        network_interface_name          = "${coalesce(pe.name, "${sa_key}-${pe.subresource_name}")}-nic"

        location = var.locations[sa.location_key_reference]

        resource_group_name = (
          pe.resource_group_key_reference != null
          ? module.resource_groups[pe.resource_group_key_reference].name
          : module.resource_groups[sa.resource_group_key_reference].name
        )

        role_assignments = pe.role_assignments
        tags             = pe.tags

        lock = (
          length([
            for group in pe.lock_groups_key_reference :
            group if contains(keys(local.locked_groups), group)
          ]) > 0
          ? (
            anytrue([
              for group in pe.lock_groups_key_reference :
              contains(keys(local.locked_groups), group)
              && try(local.locked_groups[group].read_only, false)
            ])
            ? { kind = local.lock_modes.read_only }
            : { kind = local.lock_modes.no_delete }
          )
          : null
        )

        ip_configurations = pe.private_ip != null ? {
          primary = {
            name               = "primary"
            private_ip_address = pe.private_ip
          }
        } : {}
      }
    }
  }
}
